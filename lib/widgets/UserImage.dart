import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPick});
  final void Function(File pickedImage) onPick;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedImageFile;

  void pickImage() async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedImage == null) return;

    setState(() {
      pickedImageFile = File(pickedImage.path);
    });
    widget.onPick(pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[300],
          foregroundImage: pickedImageFile != null ? FileImage(pickedImageFile!) : null,
          child: pickedImageFile == null
              ? Icon(
            Icons.person,
            size: 60,
            color: Colors.grey[700],
          )
              : null,
        ),
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: pickImage,
          icon: Icon(
            Icons.image,
            color: Colors.white,
          ),
          label: Text(
            "Add Image",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
