PDF to Excel Converter: Extract Tables from PDF into Excel Format

1. Project Description  
   The PDF to Excel Converter is a cross-platform mobile and web application that allows users to upload a PDF file containing tabular data and converts all detected tables into an Excel file. The Excel file is then automatically downloaded on the user’s device. It is ideal for students, professionals, and data handlers who want quick table extraction from PDFs.

2. Features  
   ✅ Upload PDF from web or mobile  
   ✅ Extract all tables from multi-page PDFs  
   ✅ Download Excel file with multiple sheets (each table = 1 sheet)  
   ✅ Automatic saving to Downloads folder (mobile)  
   ✅ Web version supports direct Excel download  
   ✅ Real-time processing feedback (loading indicators and messages)  
   ✅ Mobile-friendly and responsive Flutter UI  
   ✅ Automatically opens Excel file after saving (mobile)

3. Hardware Requirements  
   - Android Mobile / PC / Laptop  
   - Internet or Localhost connectivity  
   - Local Python environment (for backend)

4. Software Requirements  
   - Operating System: Windows / Linux / macOS / Android  
   - Frontend: Flutter 3.13+  
   - Backend: Python 3.8+ with Flask  
   - Required Packages:

     Flutter: 
     - `http`  
     - `file_picker`  
     - `open_filex`  
     - `permission_handler`  
     - `universal_html`  
     - `path_provider`

     Python:
     - `Flask`  
     - `Flask-CORS`  
     - `pdfplumber`  
     - `pandas`  
     - `openpyxl`

5. Installation & Setup Instructions  

   📱 Frontend (Flutter):
   1. Open terminal in `pdf_to_excel_flutter` folder  
   2. Run: `flutter pub get`  
   3. For web: `flutter run -d chrome`  
   4. For Android: `flutter run` (ensure device/emulator is connected)  

   🧠 Backend (Flask):
   1. Go to `pdf_to_excel_backend` folder  
   2. Run: `pip install -r requirements.txt`  
   3. Start server: `python app.py`  

   📂 Folder Setup:  
   - `uploads/` — Stores uploaded PDF files  
   - `excels/` — Stores generated Excel files  


License  
This project is open for academic and learning purposes. Not licensed for commercial redistribution.
