import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService{
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  Future<void> uploadFile() async{
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if(pickedFile==null) return;

    File file = File(pickedFile.path);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference _storageRef = _storage.ref().child('uploads/$fileName.jpg');
    try{
      UploadTask uploadTask = _storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();


      await _db.collection('files').add({
        "fileName": fileName,
        "fileUrl": downloadUrl,
        "uploadedAt": FieldValue.serverTimestamp(),
      });

    }catch(e){
      print("Upload Error: $e");
    }
  }


  Stream<QuerySnapshot> getFiles() {
    return _db.collection('files').orderBy('uploadedAt', descending: true).snapshots();
  }
}