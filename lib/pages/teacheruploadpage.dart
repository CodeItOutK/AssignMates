import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/assignments.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class TeacherUploadPage extends StatefulWidget {
  final String id;

  TeacherUploadPage({
    required this.id,
  });

  @override
  _TeacherUploadPageState createState() => _TeacherUploadPageState();
}

class _TeacherUploadPageState extends State<TeacherUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _title = TextEditingController();
  List<File> _files = [];
  List<Map<String, String>> _selectedClasses = [];
  String _branch = 'CS';
  String _year = '1st Year';
  String _section = 'A';
  bool _isLoading = false; // Loading state

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _files.add(File(result.files.single.path!));
      });
    }
  }

  void _addClass() {
    setState(() {
      _selectedClasses.add({
        'branch': _branch,
        'year': _year,
        'section': _section,
      });
      // Clear values after adding class
      _branch = 'Select Branch';
      _year = 'Select Year';
      _section = 'Select Section';
    });
  }

  void _removeClass(int index) {
    setState(() {
      _selectedClasses.removeAt(index);
    });
  }

  void _removeFile(int index) {
    setState(() {
      _files.removeAt(index);
    });
  }

  DateTime _selectedDate = DateTime.now(); // Initially set to current date and time

  Future<void> _pickDeadline(BuildContext context) async {
    // Show date-time picker and set the selected date
    final DateTime? picked = await DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      locale: LocaleType.en,
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _deadlineController.text = _selectedDate.toString();
      });
    }
  }

  void _uploadAssignment() async {
    if (_formKey.currentState!.validate() && _files.isNotEmpty) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        // Upload files to Firebase Storage and get URLs
        List<String> fileUrls = [];
        for (File file in _files) {
          String fileName = file.path.split('/').last;
          FirebaseStorage storage = FirebaseStorage.instance;
          Reference ref = storage.ref().child('assignments/$fileName');
          UploadTask uploadTask = ref.putFile(file);

          // Show upload progress
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            // You can show the progress if needed
            print(
                'Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
          });

          TaskSnapshot taskSnapshot = await uploadTask;
          String fileUrl = await taskSnapshot.ref.getDownloadURL();
          fileUrls.add(fileUrl);
        }

        // Create an assignment object
        Assignment assignment = Assignment(
          title: _title.text,
          id: Uuid().v4(),
          teacherId: widget.id, // Replace with actual teacher ID
          fileUrls: fileUrls,
          classes: _selectedClasses,
          instructions: _instructionsController.text,
          deadline: _selectedDate,
        );

        // Save the assignment data to Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore
            .collection('assignments')
            .doc(assignment.id)
            .set(assignment.toJson());

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Assignment uploaded successfully')));
      } catch (e) {
        // Handle errors
        print("Error uploading assignment: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload assignment')));
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a file and fill all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Assignment')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: InputDecoration(labelText: 'Assignment Title:',),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ('Please enter assignment name');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30,),
                Text('Select the Assignment PDFs'),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: Text('Pick File'),
                ),
                if (_files.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_files[index].path.split('/').last),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeFile(index),
                        ),
                      );
                    },
                  ),
                SizedBox(height: 30),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: DropdownButtonFormField(
                            value: _branch,
                            items: [
                              'Select Branch',
                              'CS',
                              'E&I',
                              'MECH'
                                  'CIVIL'
                                  'ETC',
                              'IT',
                            ].map((String branch) {
                              return DropdownMenuItem(
                                value: branch,
                                child: Text(branch,
                                  style: TextStyle(fontSize: 10),),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _branch = newValue.toString();
                              });
                            },
                            decoration: InputDecoration(labelText: 'Branch'),
                          ),
                        ),
                        SizedBox(width: 4),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: DropdownButtonFormField(
                            value: _year,
                            items: [
                              'Select Year',
                              '1st Year',
                              '2nd Year',
                              '3rd Year',
                              '4th Year'
                            ].map((String year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year,
                                  style: TextStyle(fontSize: 10),),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _year = newValue.toString();
                              });
                            },
                            decoration: InputDecoration(labelText: 'Year'),
                          ),
                        ),
                        SizedBox(width: 4),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: DropdownButtonFormField(
                            value: _section,
                            items: [
                              'Select Section',
                              'A',
                              'B',
                              'C'
                            ].map((String section) {
                              return DropdownMenuItem(
                                value: section,
                                child: Text(section,
                                  style: TextStyle(fontSize: 10),),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _section = newValue.toString();
                              });
                            },
                            decoration: InputDecoration(labelText: 'Section'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _addClass,
                  child: Text('Add Class'),
                ),
                if (_selectedClasses.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _selectedClasses.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          '${_selectedClasses[index]['branch']} ${_selectedClasses[index]['year']} ${_selectedClasses[index]['section']}',
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removeClass(index),
                        ),
                      );
                    },
                  ),
                TextFormField(
                  controller: _instructionsController,
                  decoration: InputDecoration(labelText: 'Instructions'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return ('Please enter instructions');
                    }
                    return null;
                  },
                ),
                TextFormField(
                    controller: _deadlineController,
                    decoration: InputDecoration(labelText: 'Deadline'),
                    readOnly: true,
                    onTap: () async{
                      await _pickDeadline(context);
                    }
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _uploadAssignment();
                    }
                  },
                  child: Text('Submit'),
                ),
                if (_isLoading)
                  CircularProgressIndicator(), // Show loading indicator when uploading
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:uuid/uuid.dart';
// import '../models/assignments.dart';
//
// class TeacherUploadPage extends StatefulWidget {
//   final String id;
//
//   @override
//   TeacherUploadPage({
//     required this.id,
//   });
//   _TeacherUploadPageState createState() => _TeacherUploadPageState();
// }
//
// class _TeacherUploadPageState extends State<TeacherUploadPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _instructionsController = TextEditingController();
//   final TextEditingController _deadlineController = TextEditingController();
//   final TextEditingController _title=TextEditingController();
//   List<File> _files = [];
//   List<Map<String, String>> _selectedClasses = [];
//   String _branch = 'CSE';
//   String _year = '1st Year';
//   String _section = 'A';
//   bool _isLoading = false; // Loading state
//
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//
//     if (result != null) {
//       setState(() {
//         _files.add(File(result.files.single.path!));
//       });
//     }
//   }
//
//   void _addClass() {
//     setState(() {
//       _selectedClasses.add({
//         'branch': _branch,
//         'year': _year,
//         'section': _section,
//       });
//       // Clear values after adding class
//       _branch = 'Select Branch';
//       _year = 'Select Year';
//       _section = 'Select Section';
//     });
//   }
//
//   void _removeClass(int index) {
//     setState(() {
//       _selectedClasses.removeAt(index);
//     });
//   }
//
//   void _removeFile(int index) {
//     setState(() {
//       _files.removeAt(index);
//     });
//   }
//
//   void _pickDeadline() async {
//     DateTime? selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2101),
//     );
//
//     if (selectedDate != null) {
//       setState(() {
//         _deadlineController.text = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
//       });
//     }
//   }
//
//   void _uploadAssignment() async {
//     if (_formKey.currentState!.validate() && _files.isNotEmpty) {
//       setState(() {
//         _isLoading = true; // Show loading indicator
//       });
//
//       try {
//         // Upload files to Firebase Storage and get URLs
//         List<String> fileUrls = [];
//         for (File file in _files) {
//           String fileName = file.path.split('/').last;
//           FirebaseStorage storage = FirebaseStorage.instance;
//           Reference ref = storage.ref().child('assignments/$fileName');
//           UploadTask uploadTask = ref.putFile(file);
//
//           // Show upload progress
//           uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
//             // You can show the progress if needed
//             print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
//           });
//
//           TaskSnapshot taskSnapshot = await uploadTask;
//           String fileUrl = await taskSnapshot.ref.getDownloadURL();
//           fileUrls.add(fileUrl);
//         }
//
//         // Create an assignment object
//         Assignment assignment = Assignment(
//           title: _title.text,
//           id: Uuid().v4(),
//           teacherId: widget.id, // Replace with actual teacher ID
//           fileUrls: fileUrls,
//           classes: _selectedClasses,
//           instructions: _instructionsController.text,
//           deadline: _deadlineController.text,
//         );
//
//         // Save the assignment data to Firestore
//         FirebaseFirestore firestore = FirebaseFirestore.instance;
//         await firestore.collection('assignments').doc(assignment.id).set(assignment.toJson());
//
//         // Show a success message
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assignment uploaded successfully')));
//       } catch (e) {
//         // Handle errors
//         print("Error uploading assignment: $e");
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload assignment')));
//       } finally {
//         setState(() {
//           _isLoading = false; // Hide loading indicator
//         });
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a file and fill all fields')));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Upload Assignment')),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 TextFormField(
//                   controller: _title,
//                   decoration: InputDecoration(labelText: 'Assignment Title:',),
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return ('Please enter assignment name');
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 30,),
//                 Text('Select the Assignment PDFs'),
//                 ElevatedButton(
//                   onPressed: _pickFile,
//                   child: Text('Pick File'),
//                 ),
//                 if (_files.isNotEmpty)
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: _files.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(_files[index].path.split('/').last),
//                         trailing: IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () => _removeFile(index),
//                         ),
//                       );
//                     },
//                   ),
//                 SizedBox(height: 30),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Container(
//                     margin: EdgeInsets.all(4),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: MediaQuery.of(context).size.width * 0.3,
//                           child: DropdownButtonFormField(
//                             value: _branch,
//                             items: [
//                               'Select Branch',
//                               'CSE',
//                               'ECE',
//                               'MECH'
//                             ].map((String branch) {
//                               return DropdownMenuItem(
//                                 value: branch,
//                                 child: Text(branch,
//                                   style: TextStyle(fontSize: 10),),
//                               );
//                             }).toList(),
//                             onChanged: (newValue) {
//                               setState(() {
//                                 _branch = newValue.toString();
//                               });
//                             },
//                             decoration: InputDecoration(labelText: 'Branch'),
//                           ),
//                         ),
//                         SizedBox(width: 4),
//                         Container(
//                           width: MediaQuery.of(context).size.width * 0.3,
//                           child: DropdownButtonFormField(
//                             value: _year,
//                             items: [
//                               'Select Year',
//                               '1st Year',
//                               '2nd Year',
//                               '3rd Year',
//                               '4th Year'
//                             ].map((String year) {
//                               return DropdownMenuItem(
//                                 value: year,
//                                 child: Text(year,
//                                   style: TextStyle(fontSize: 10),),
//                               );
//                             }).toList(),
//                             onChanged: (newValue) {
//                               setState(() {
//                                 _year = newValue.toString();
//                               });
//                             },
//                             decoration: InputDecoration(labelText: 'Year'),
//                           ),
//                         ),
//                         SizedBox(width: 4),
//                         Container(
//                           width: MediaQuery.of(context).size.width * 0.3,
//                           child: DropdownButtonFormField(
//                             value: _section,
//                             items: [
//                               'Select Section',
//                               'A',
//                               'B',
//                               'C'
//                             ].map((String section) {
//                               return DropdownMenuItem(
//                                 value: section,
//                                 child: Text(section,
//                                   style: TextStyle(fontSize: 10),),
//                               );
//                             }).toList(),
//                             onChanged: (newValue) {
//                               setState(() {
//                                 _section = newValue.toString();
//                               });
//                             },
//                             decoration: InputDecoration(labelText: 'Section'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 30),
//                 ElevatedButton(
//                   onPressed: _addClass,
//                   child: Text('Add Class'),
//                 ),
//                 if (_selectedClasses.isNotEmpty)
//                   ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: _selectedClasses.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         title: Text(
//                           '${_selectedClasses[index]['branch']} ${_selectedClasses[index]['year']} ${_selectedClasses[index]['section']}',
//                         ),
//                         trailing: IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: () => _removeClass(index),
//                         ),
//                       );
//                     },
//                   ),
//                 TextFormField(
//                   controller: _instructionsController,
//                   decoration: InputDecoration(labelText: 'Instructions'),
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return ('Please enter instructions');
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _deadlineController,
//                   decoration: InputDecoration(labelText: 'Deadline'),
//                   readOnly: true,
//                   onTap: _pickDeadline,
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       _uploadAssignment();
//                     }
//                   },
//                   child: Text('Submit'),
//                 ),
//                 if (_isLoading)
//                   CircularProgressIndicator(), // Show loading indicator when uploading
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// // import 'dart:io';
// //
// // import 'package:file_picker/file_picker.dart';
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_storage/firebase_storage.dart';
// // import 'package:uuid/uuid.dart';
// //
// // import '../models/assignments.dart';
// //
// // class TeacherUploadPage extends StatefulWidget {
// //   @override
// //   _TeacherUploadPageState createState() => _TeacherUploadPageState();
// // }
// //
// // class _TeacherUploadPageState extends State<TeacherUploadPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final TextEditingController _instructionsController = TextEditingController();
// //   final TextEditingController _deadlineController = TextEditingController();
// //   List<File> _files = [];
// //   List<Map<String, String>> _selectedClasses = [];
// //   String _branch = 'CSE';
// //   String _year = '1st Year';
// //   String _section = 'A';
// //   bool _isLoading = false; // Loading state
// //
// //   Future<void> _pickFile() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles();
// //
// //     if (result != null) {
// //       setState(() {
// //         _files.add(File(result.files.single.path!));
// //       });
// //     }
// //   }
// //
// //   void _addClass() {
// //     setState(() {
// //       _selectedClasses.add({
// //         'branch': _branch,
// //         'year': _year,
// //         'section': _section,
// //       });
// //       // Clear values after adding class
// //       _branch = 'Select Branch';
// //       _year = 'Select Year';
// //       _section = 'Select Section';
// //     });
// //   }
// //
// //   void _removeClass(int index) {
// //     setState(() {
// //       _selectedClasses.removeAt(index);
// //     });
// //   }
// //
// //   void _removeFile(int index) {
// //     setState(() {
// //       _files.removeAt(index);
// //     });
// //   }
// //
// //   void _pickDeadline() async {
// //     DateTime? selectedDate = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2101),
// //     );
// //
// //     if (selectedDate != null) {
// //       setState(() {
// //         _deadlineController.text = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
// //       });
// //     }
// //   }
// //   //
// //   // void _uploadAssignment() async {
// //   //   if (_formKey.currentState!.validate() && _files.isNotEmpty) {
// //   //     setState(() {
// //   //       _isLoading = true; // Show loading indicator
// //   //     });
// //   //
// //   //     try {
// //   //       // Upload files to Firebase Storage and get URLs
// //   //       List<String> fileUrls = [];
// //   //       for (File file in _files) {
// //   //         String fileName = file.path.split('/').last;
// //   //         FirebaseStorage storage = FirebaseStorage.instance;
// //   //         Reference ref = storage.ref().child('assignments/$fileName');
// //   //         UploadTask uploadTask = ref.putFile(file);
// //   //
// //   //         // Show upload progress
// //   //         uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
// //   //           // You can show the progress if needed
// //   //           print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
// //   //         });
// //   //
// //   //         TaskSnapshot taskSnapshot = await uploadTask;
// //   //         String fileUrl = await taskSnapshot.ref.getDownloadURL();
// //   //         fileUrls.add(fileUrl);
// //   //       }
// //   //
// //   //       // Create an assignment object
// //   //       Assignment assignment = Assignment(
// //   //         id: Uuid().v4(),
// //   //         teacherId: 'teacher-id', // Replace with actual teacher ID
// //   //         fileUrls: fileUrls,
// //   //         classes: _selectedClasses,
// //   //         instructions: _instructionsController.text,
// //   //         deadline: _deadlineController.text,
// //   //       );
// //   //
// //   //       // Save the assignment data to Firestore
// //   //       FirebaseFirestore firestore = FirebaseFirestore.instance;
// //   //       await firestore.collection('assignments').doc(assignment.id).set(assignment.toJson());
// //   //
// //   //       // Show a success message
// //   //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assignment uploaded successfully')));
// //   //     } catch (e) {
// //   //       // Handle errors
// //   //       print("Error uploading assignment: $e");
// //   //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload assignment')));
// //   //     } finally {
// //   //       setState(() {
// //   //         _isLoading = false; // Hide loading indicator
// //   //       });
// //   //     }
// //   //   } else {
// //   //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a file and fill all fields')));
// //   //   }
// //   // }
// //
// //   void _uploadAssignment() async {
// //     if (_formKey.currentState!.validate() && _files.isNotEmpty) {
// //       //Upload files to Firebase Storage and get URLs
// //       List<String> fileUrls = [];
// //       for (File file in _files) {
// //         String fileName = file.path.split('/').last;
// //         FirebaseStorage storage = FirebaseStorage.instance;
// //         Reference ref = storage.ref().child('assignments/$fileName');
// //         UploadTask uploadTask = ref.putFile(file);
// //         TaskSnapshot taskSnapshot = await uploadTask;
// //         String fileUrl = await taskSnapshot.ref.getDownloadURL();
// //         fileUrls.add(fileUrl);
// //       }
// //
// //       // Create an assignment object
// //       Assignment assignment = Assignment(
// //         id: Uuid().v4(),
// //         teacherId: 'teacher-id', // Replace with actual teacher ID
// //         fileUrls: fileUrls,
// //         classes: _selectedClasses,
// //         instructions: _instructionsController.text,
// //         deadline: _deadlineController.text,
// //       );
// //
// //       // Save the assignment data to Firestore
// //       FirebaseFirestore firestore = FirebaseFirestore.instance;
// //       await firestore.collection('assignments').doc(assignment.id).set(assignment.toJson());
// //
// //       // Show a success message
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assignment uploaded successfully')));
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Upload Assignment')),
// //       body: Form(
// //         key: _formKey,
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               children: [
// //                 ElevatedButton(
// //                   onPressed: _pickFile,
// //                   child: Text('Pick File'),
// //                 ),
// //                 if (_files.isNotEmpty)
// //                   ListView.builder(
// //                     shrinkWrap: true,
// //                     itemCount: _files.length,
// //                     itemBuilder: (context, index) {
// //                       return ListTile(
// //                         title: Text(_files[index].path.split('/').last),
// //                         trailing: IconButton(
// //                           icon: Icon(Icons.delete),
// //                           onPressed: () => _removeFile(index),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: DropdownButtonFormField(
// //                         value: _branch,
// //                         items: [
// //                           'Select Branch',
// //                           'CSE',
// //                           'ECE',
// //                           'MECH'
// //                         ].map((String branch) {
// //                           return DropdownMenuItem(
// //                             value: branch,
// //                             child: Text(branch),
// //                           );
// //                         }).toList(),
// //                         onChanged: (newValue) {
// //                           setState(() {
// //                             _branch = newValue.toString();
// //                           });
// //                         },
// //                         decoration: InputDecoration(labelText: 'Branch'),
// //                       ),
// //                     ),
// //                     SizedBox(width: 10),
// //                     Expanded(
// //                       child: DropdownButtonFormField(
// //                         value: _year,
// //                         items: [
// //                           'Select Year',
// //                           '1st Year',
// //                           '2nd Year',
// //                           '3rd Year',
// //                           '4th Year'
// //                         ].map((String year) {
// //                           return DropdownMenuItem(
// //                             value: year,
// //                             child: Text(year),
// //                           );
// //                         }).toList(),
// //                         onChanged: (newValue) {
// //                           setState(() {
// //                             _year = newValue.toString();
// //                           });
// //                         },
// //                         decoration: InputDecoration(labelText: 'Year'),
// //                       ),
// //                     ),
// //                     SizedBox(width: 10),
// //                     Expanded(
// //                       child: DropdownButtonFormField(
// //                         value: _section,
// //                         items: [
// //                           'Select Section',
// //                           'A',
// //                           'B',
// //                           'C'
// //                         ].map((String section) {
// //                           return DropdownMenuItem(
// //                             value: section,
// //                             child: Text(section),
// //                           );
// //                         }).toList(),
// //                         onChanged: (newValue) {
// //                           setState(() {
// //                             _section = newValue.toString();
// //                           });
// //                         },
// //                         decoration: InputDecoration(labelText: 'Section'),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: _addClass,
// //                   child: Text('Add Class'),
// //                 ),
// //                 if (_selectedClasses.isNotEmpty)
// //                   ListView.builder(
// //                     shrinkWrap: true,
// //                     itemCount: _selectedClasses.length,
// //                     itemBuilder: (context, index) {
// //                       return ListTile(
// //                         title: Text(
// //                           '${_selectedClasses[index]['branch']} ${_selectedClasses[index]['year']} ${_selectedClasses[index]['section']}',
// //                         ),
// //                         trailing: IconButton(
// //                           icon: Icon(Icons.delete),
// //                           onPressed: () => _removeClass(index),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 TextFormField(
// //                   controller: _instructionsController,
// //                   decoration: InputDecoration(labelText: 'Instructions'),
// //                   validator: (value) {
// //                     if (value!.isEmpty) {
// //                       return 'Please enter instructions';
// //                     }
// //                     return null;
// //                   },
// //                 ),
// //                 TextFormField(
// //                   controller: _deadlineController,
// //                   decoration: InputDecoration(labelText: 'Deadline'),
// //                   readOnly: true,
// //                   onTap: _pickDeadline,
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     if (_formKey.currentState!.validate()) {
// //                       _uploadAssignment();
// //                     }
// //                   },
// //                   child: Text('Submit'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Upload Assignment')),
// // //       body: Form(
// // //         key: _formKey,
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(16.0),
// // //           child: SingleChildScrollView(
// // //             child: Column(
// // //               children: [
// // //                 ElevatedButton(
// // //                   onPressed: _pickFile,
// // //                   child: Text('Pick File'),
// // //                 ),
// // //                 if (_files.isNotEmpty)
// // //                   ListView.builder(
// // //                     shrinkWrap: true,
// // //                     itemCount: _files.length,
// // //                     itemBuilder: (context, index) {
// // //                       return ListTile(
// // //                         title: Text(_files[index].path.split('/').last),
// // //                         trailing: IconButton(
// // //                           icon: Icon(Icons.delete),
// // //                           onPressed: () => _removeFile(index),
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 Row(
// // //                   children: [
// // //                     Expanded(
// // //                       child: DropdownButtonFormField(
// // //                         value: _branch,
// // //                         items: ['CSE', 'ECE', 'MECH'].map((String branch) {
// // //                           return DropdownMenuItem(value: branch, child: Text(branch));
// // //                         }).toList(),
// // //                         onChanged: (newValue) {
// // //                           setState(() {
// // //                             _branch = newValue.toString();
// // //                           });
// // //                         },
// // //                         decoration: InputDecoration(labelText: 'Branch'),
// // //                       ),
// // //                     ),
// // //                     SizedBox(width: 10),
// // //                     Expanded(
// // //                       child: DropdownButtonFormField(
// // //                         value: _year,
// // //                         items: ['1st Year', '2nd Year', '3rd Year', '4th Year'].map((String year) {
// // //                           return DropdownMenuItem(value: year, child: Text(year));
// // //                         }).toList(),
// // //                         onChanged: (newValue) {
// // //                           setState(() {
// // //                             _year = newValue.toString();
// // //                           });
// // //                         },
// // //                         decoration: InputDecoration(labelText: 'Year'),
// // //                       ),
// // //                     ),
// // //                     SizedBox(width: 10),
// // //                     Expanded(
// // //                       child: DropdownButtonFormField(
// // //                         value: _section,
// // //                         items: ['A', 'B', 'C'].map((String section) {
// // //                           return DropdownMenuItem(value: section, child: Text(section));
// // //                         }).toList(),
// // //                         onChanged: (newValue) {
// // //                           setState(() {
// // //                             _section = newValue.toString();
// // //                           });
// // //                         },
// // //                         decoration: InputDecoration(labelText: 'Section'),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 ElevatedButton(
// // //                   onPressed: _addClass,
// // //                   child: Text('Add Class'),
// // //                 ),
// // //                 if (_selectedClasses.isNotEmpty)
// // //                   ListView.builder(
// // //                     shrinkWrap: true,
// // //                     itemCount: _selectedClasses.length,
// // //                     itemBuilder: (context, index) {
// // //                       return ListTile(
// // //                         title: Text(
// // //                           '${_selectedClasses[index]['branch']} ${_selectedClasses[index]['year']} ${_selectedClasses[index]['section']}',
// // //                         ),
// // //                         trailing: IconButton(
// // //                           icon: Icon(Icons.delete),
// // //                           onPressed: () => _removeClass(index),
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 TextFormField(
// // //                   controller: _instructionsController,
// // //                   decoration: InputDecoration(labelText: 'Instructions'),
// // //                   validator: (value) {
// // //                     if (value!.isEmpty) {
// // //                       return 'Please enter instructions';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 TextFormField(
// // //                   controller: _deadlineController,
// // //                   decoration: InputDecoration(labelText: 'Deadline'),
// // //                   readOnly: true,
// // //                   onTap: _pickDeadline,
// // //                 ),
// // //                 ElevatedButton(
// // //                   onPressed: _uploadAssignment,
// // //                   child: Text('Submit'),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Upload Assignment')),
// // //       body: Form(
// // //         key: _formKey,
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(16.0),
// // //           child: SingleChildScrollView(
// // //             child: Column(
// // //               children: [
// // //                 ElevatedButton(
// // //                   onPressed: _pickFile,
// // //                   child: Text('Pick File'),
// // //                 ),
// // //                 if (_files.isNotEmpty)
// // //                   ListView.builder(
// // //                     shrinkWrap: true,
// // //                     itemCount: _files.length,
// // //                     itemBuilder: (context, index) {
// // //                       return ListTile(
// // //                         title: Text(_files[index].path.split('/').last),
// // //                       );
// // //                     },
// // //                   ),
// // //                 Row(
// // //                   children: [
// // //                     Expanded(
// // //                       child: DropdownButtonFormField(
// // //                         value: _branch,
// // //                         items: ['CSE', 'ECE', 'MECH'].map((String branch) {
// // //                           return DropdownMenuItem(value: branch, child: Text(branch));
// // //                         }).toList(),
// // //                         onChanged: (newValue) {
// // //                           setState(() {
// // //                             _branch = newValue.toString();
// // //                           });
// // //                         },
// // //                         decoration: InputDecoration(labelText: 'Branch'),
// // //                       ),
// // //                     ),
// // //                     SizedBox(width: 10),
// // //                     Expanded(
// // //                       child: DropdownButtonFormField(
// // //                         value: _year,
// // //                         items: ['1st Year', '2nd Year', '3rd Year', '4th Year'].map((String year) {
// // //                           return DropdownMenuItem(value: year, child: Text(year));
// // //                         }).toList(),
// // //                         onChanged: (newValue) {
// // //                           setState(() {
// // //                             _year = newValue.toString();
// // //                           });
// // //                         },
// // //                         decoration: InputDecoration(labelText: 'Year'),
// // //                       ),
// // //                     ),
// // //                     SizedBox(width: 10),
// // //                     Expanded(
// // //                       child: DropdownButtonFormField(
// // //                         value: _section,
// // //                         items: ['A', 'B', 'C'].map((String section) {
// // //                           return DropdownMenuItem(value: section, child: Text(section));
// // //                         }).toList(),
// // //                         onChanged: (newValue) {
// // //                           setState(() {
// // //                             _section = newValue.toString();
// // //                           });
// // //                         },
// // //                         decoration: InputDecoration(labelText: 'Section'),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 ElevatedButton(
// // //                   onPressed: _addClass,
// // //                   child: Text('Add Class'),
// // //                 ),
// // //                 if (_selectedClasses.isNotEmpty)
// // //                   ListView.builder(
// // //                     shrinkWrap: true,
// // //                     itemCount: _selectedClasses.length,
// // //                     itemBuilder: (context, index) {
// // //                       return ListTile(
// // //                         title: Text(
// // //                           '${_selectedClasses[index]['branch']} ${_selectedClasses[index]['year']} ${_selectedClasses[index]['section']}',
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 TextFormField(
// // //                   controller: _instructionsController,
// // //                   decoration: InputDecoration(labelText: 'Instructions'),
// // //                   validator: (value) {
// // //                     if (value!.isEmpty) {
// // //                       return 'Please enter instructions';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 TextFormField(
// // //                   controller: _deadlineController,
// // //                   decoration: InputDecoration(labelText: 'Deadline'),
// // //                   onTap: () {
// // //                     FocusScope.of(context).requestFocus(FocusNode());
// // //                     _pickDeadline();
// // //                   },
// // //                   validator: (value) {
// // //                     if (value!.isEmpty) {
// // //                       return 'Please enter a deadline';
// // //                     }
// // //                     return null;
// // //                   },
// // //                 ),
// // //                 ElevatedButton(
// // //                   onPressed: _uploadAssignment,
// // //                   child: Text('Upload Assignment'),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // // import 'dart:io';
// // //
// // // import 'package:file_picker/file_picker.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:flutter/cupertino.dart';
// // // import 'package:flutter/material.dart';
// // //
// // // class TeacherUploadPage extends StatefulWidget {
// // //   @override
// // //   _TeacherUploadPageState createState() => _TeacherUploadPageState();
// // // }
// // //
// // // class _TeacherUploadPageState extends State<TeacherUploadPage> {
// // //   File? _file;
// // //   final _formKey = GlobalKey<FormState>();
// // //   final TextEditingController _instructionsController = TextEditingController();
// // //   final TextEditingController _deadlineController = TextEditingController();
// // //   String _branch = 'CSE';
// // //   String _year = '1st Year';
// // //
// // //   Future<void> _pickFile() async {
// // //     FilePickerResult? result = await FilePicker.platform.pickFiles();
// // //
// // //     if (result != null) {
// // //       setState(() {
// // //         _file = File(result.files.single.path!);
// // //       });
// // //     }
// // //   }
// // //
// // //   void _uploadAssignment() async {
// // //     if (_formKey.currentState!.validate()) {
// // //       // Upload file to Firebase Storage and get the URL
// // //       // Save the assignment data to Firestore
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Upload Assignment')),
// // //       body: Form(
// // //         key: _formKey,
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(16.0),
// // //           child: Column(
// // //             children: [
// // //               ElevatedButton(
// // //                 onPressed: _pickFile,
// // //                 child: Text('Pick File'),
// // //               ),
// // //               DropdownButtonFormField(
// // //                 value: _branch,
// // //                 items: ['CSE', 'ECE', 'MECH'].map((String branch) {
// // //                   return DropdownMenuItem(value: branch, child: Text(branch));
// // //                 }).toList(),
// // //                 onChanged: (newValue) {
// // //                   setState(() {
// // //                     _branch = newValue.toString();
// // //                   });
// // //                 },
// // //                 decoration: InputDecoration(labelText: 'Branch'),
// // //               ),
// // //               DropdownButtonFormField(
// // //                 value: _year,
// // //                 items: ['1st Year', '2nd Year', '3rd Year', '4th Year'].map((String year) {
// // //                   return DropdownMenuItem(value: year, child: Text(year));
// // //                 }).toList(),
// // //                 onChanged: (newValue) {
// // //                   setState(() {
// // //                     _year = newValue.toString();
// // //                   });
// // //                 },
// // //                 decoration: InputDecoration(labelText: 'Year'),
// // //               ),
// // //               TextFormField(
// // //                 controller: _instructionsController,
// // //                 decoration: InputDecoration(labelText: 'Instructions'),
// // //                 validator: (value) {
// // //                   if (value!.isEmpty) {
// // //                     return 'Please enter instructions';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               TextFormField(
// // //                 controller: _deadlineController,
// // //                 decoration: InputDecoration(labelText: 'Deadline'),
// // //                 validator: (value) {
// // //                   if (value!.isEmpty) {
// // //                     return 'Please enter a deadline';
// // //                   }
// // //                   return null;
// // //                 },
// // //               ),
// // //               ElevatedButton(
// // //                 onPressed: _uploadAssignment,
// // //                 child: Text('Upload Assignment'),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
