import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File? _mediaFile;
  bool _isUploading = false;
  final TextEditingController _captionController = TextEditingController();

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Cambiar a pickVideo para videos
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_mediaFile == null) return;
    setState(() {
      _isUploading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final storageRef = FirebaseStorage.instance.ref().child('posts').child('${DateTime.now()}.jpg');
      await storageRef.putFile(_mediaFile!);
      final mediaUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': userId,
        'mediaUrl': mediaUrl,
        'caption': _captionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post subido con éxito!')));
      _captionController.clear();
      setState(() {
        _mediaFile = null;
        _isUploading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar', style: TextStyle(fontFamily: 'Billabong', fontSize: 24)),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickMedia,
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: _mediaFile == null
                    ? const Center(child: Text('Selecciona una imagen o video'))
                    : Image.file(_mediaFile!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: 'Escribe un pie de foto...'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadPost,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Subir Publicación'),
            ),
          ],
        ),
      ),
    );
  }
}
