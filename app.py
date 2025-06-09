from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import os
import pdfplumber
import pandas as pd
from werkzeug.utils import secure_filename

app = Flask(__name__)
CORS(app)  

UPLOAD_FOLDER = 'uploads'
EXCEL_FOLDER = 'excels'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(EXCEL_FOLDER, exist_ok=True)

@app.route('/upload-pdf', methods=['POST'])
def upload_pdf():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400

    file = request.files['file']
    filename = secure_filename(file.filename)
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)

    # Extract tables
    tables = []
    with pdfplumber.open(filepath) as pdf:
        for page in pdf.pages:
            for table in page.extract_tables():
                df = pd.DataFrame(table[1:], columns=table[0])
                tables.append(df)

    if not tables:
        return jsonify({"error": "No tables found"}), 400

    # Save to Excel
    excel_path = os.path.join(EXCEL_FOLDER, filename.replace('.pdf', '.xlsx'))
    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        for i, df in enumerate(tables):
            df.to_excel(writer, sheet_name=f'Table_{i+1}', index=False)

    return send_file(excel_path, as_attachment=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
 
