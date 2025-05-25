import 'package:firestore_demo/file_list_widget.dart';
import 'package:firestore_demo/storage_service.dart';
import 'package:flutter/material.dart';

class UploadScreen extends StatelessWidget {
  UploadScreen({super.key});

  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload & Manage Files")),
      body: FileListWidget(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.upload),
        onPressed: () => _storageService.uploadFile(),
      ),
    );
  }
}
