import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart' show OpenFilex;
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class UploadPDF extends StatefulWidget {
  @override
  _UploadPDFState createState() => _UploadPDFState();
}

class _UploadPDFState extends State<UploadPDF> {
  bool isLoading = false;
  String statusMessage = '';

  Future<void> pickPDFAndUpload() async {
    setState(() {
      isLoading = true;
      statusMessage = "Picking file...";
    });

    try {
      if (kIsWeb) {
        final input = html.FileUploadInputElement()..accept = '.pdf';
        input.click();
        input.onChange.listen((event) async {
          final file = input.files?.first;
          final reader = html.FileReader();
          if (file != null) {
            reader.readAsArrayBuffer(file);
            reader.onLoadEnd.listen((e) async {
              Uint8List fileBytes = reader.result as Uint8List;
              await uploadFileWeb(fileBytes, file.name);
            });
          } else {
            setState(() {
              isLoading = false;
              statusMessage = "No file selected.";
            });
          }
        });
      } else {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        if (result != null && result.files.single.path != null) {
          File file = File(result.files.single.path!);
          String fileName = result.files.single.name;
          Uint8List fileBytes = await file.readAsBytes();
          await uploadFileMobile(fileBytes, fileName);
        } else {
          setState(() {
            isLoading = false;
            statusMessage = "No file selected.";
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        statusMessage = "Error: $e";
      });
    }
  }

  Future<void> uploadFileWeb(Uint8List fileBytes, String filename) async {
    final uri = Uri.parse('http://192.168.1.7:5000/upload-pdf');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: filename));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "converted_excel.xlsx")
          ..click();
        html.Url.revokeObjectUrl(url);

        setState(() {
          statusMessage = "✅ Excel downloaded successfully!";
        });
      } else {
        setState(() {
          statusMessage = "❌ Failed to convert. Status ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Upload error: $e";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> uploadFileMobile(Uint8List fileBytes, String filename) async {
    final uri = Uri.parse('http://192.168.1.7:5000/upload-pdf');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: filename));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final excelBytes = await response.stream.toBytes();

        if (await _requestPermissions()) {
          Directory? dir = Platform.isAndroid
              ? Directory('/storage/emulated/0/Download')
              : await getApplicationDocumentsDirectory();

          final path = '${dir.path}/converted_excel.xlsx';
          final file = File(path);
          await file.writeAsBytes(excelBytes);
          await OpenFilex.open(path);

          setState(() {
            statusMessage = "✅ Excel downloaded successfully!";
          });
        } else {
          setState(() {
            statusMessage = "❌ Storage permission denied.";
          });
        }
      } else {
        setState(() {
          statusMessage = "❌ Upload failed. Status ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        statusMessage = "Upload error: $e";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
        await Permission.manageExternalStorage.request();
      }
      return await Permission.manageExternalStorage.isGranted ||
          await Permission.storage.isGranted;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("PDF ➡️ Excel Converter", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.teal[600],
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 10,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 64, color: Colors.teal),
                  const SizedBox(height: 16),
                  const Text(
                    "Convert PDF to Excel",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file, color: Colors.white,),
                    label: const Text("Choose PDF & Upload", style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    onPressed: isLoading ? null : pickPDFAndUpload,
                  ),
                  const SizedBox(height: 24),
                  if (isLoading) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    const Text("Uploading & Processing..."),
                  ],
                  if (statusMessage.isNotEmpty && !isLoading)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.teal),
                      ),
                      child: Text(
                        statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
