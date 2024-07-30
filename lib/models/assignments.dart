class Assignment {
  String id;
  String teacherId;
  List<String> fileUrls;
  List<Map<String, String>> classes;
  String instructions;
  String deadline;

  Assignment({
    required this.id,
    required this.teacherId,
    required this.fileUrls,
    required this.classes,
    required this.instructions,
    required this.deadline,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'fileUrls': fileUrls,
      'classes': classes,
      'instructions': instructions,
      'deadline': deadline,
    };
  }

  static Assignment fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      teacherId: json['teacherId'],
      fileUrls: List<String>.from(json['fileUrls']),
      classes: List<Map<String, String>>.from(json['classes']),
      instructions: json['instructions'],
      deadline: json['deadline'],
    );
  }
}



// class Assignment {
//   String id;
//   String teacherId;
//   String fileUrl;
//   String branch;
//   String year;
//   String instructions;
//   String deadline;
//
//   Assignment({
//     required this.id,
//     required this.teacherId,
//     required this.fileUrl,
//     required this.branch,
//     required this.year,
//     required this.instructions,
//     required this.deadline,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'teacherId': teacherId,
//       'fileUrl': fileUrl,
//       'branch': branch,
//       'year': year,
//       'instructions': instructions,
//       'deadline': deadline,
//     };
//   }
//
//   static Assignment fromJson(Map<String, dynamic> json) {
//     return Assignment(
//       id: json['id'],
//       teacherId: json['teacherId'],
//       fileUrl: json['fileUrl'],
//       branch: json['branch'],
//       year: json['year'],
//       instructions: json['instructions'],
//       deadline: json['deadline'],
//     );
//   }
// }