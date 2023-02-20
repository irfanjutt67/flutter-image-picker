import 'dart:io';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  XFile? _image;

  final picker = ImagePicker();
  List<XFile> multipleImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Pick'),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image != null && _image!.path.isNotEmpty
                    ? Image.file(File(_image!.path))
                    : const SizedBox.shrink(),
                MaterialButton(
                    child: const Text('Single image picker'),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      imagePicker();
                    }),
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () async {
                    multipleImages = await multiImagePicker();
                    if (multipleImages.isNotEmpty) {
                      setState(() {});
                    }
                  },
                  child: const Text('Multiple image picker'),
                ),
                Wrap(
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 17,
                  runSpacing: 17,
                  children: multipleImages
                      .map(
                        (e) => Image.file(
                          File(e.path),
                          width: 200,
                          height: 100,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Single Image Picker
  Future imagePicker() async {
    final pick = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 100,
      maxHeight: 300,
    );
    if (pick != null) {
      setState(() {
        _image = XFile(pick.path);
      });
      print(await uploadImage(_image!));
    }
  }

  /// Multiple Image Picker
  Future<List<XFile>> multiImagePicker() async {
    List<XFile>? _images = await ImagePicker().pickMultiImage();
    if (_images != null && _images.isNotEmpty) {
      return _images;
    }
    cath(e) {
      print('something wrong' + e.toString());
    }

    return [];
  }

  /// Upload Image to Firebase
  Future<String> uploadImage(XFile _image) async {
    print(getImageName(_image));
    Reference db =
        FirebaseStorage.instance.ref("testFolder/${getImageName(_image)}");
    await db.putFile(File(_image.path));
    return await db.getDownloadURL();
  }

  /// Return Image Name
  String getImageName(XFile _image) {
    return _image.path.split("/").last;
  }
}
