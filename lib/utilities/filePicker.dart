import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


class PickFile extends StatefulWidget {
  const PickFile({super.key});

  @override
  State<PickFile> createState() => _PickFileState();
}

class _PickFileState extends State<PickFile> {

  List<File> _files = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _files.add(File(result.files.single.path!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}



