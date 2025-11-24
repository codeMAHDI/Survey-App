import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FileListWidget extends StatelessWidget {
  const FileListWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final StorageService _storageService = StorageService();

    return StreamBuilder<QuerySnapshot>(
      stream: _storageService.getFiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No files uploaded yet."));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            String fileName = doc["fileName"];
            String fileUrl = doc["fileUrl"];

            return ListTile(
              title: Text(fileName),
              subtitle: Text(fileUrl, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: Icon(Icons.download),
                onPressed: () async {
                  if (fileUrl.isNotEmpty) {
                    await launch(fileUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Could not open file")),
                    );
                  }
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
