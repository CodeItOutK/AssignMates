import 'package:assignmates/database/database.dart';
import 'package:flutter/material.dart';
import '../models/student.dart';

class CurvedRectangleClipper extends CustomClipper<Path> {
  final double offset = 80;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - offset);
    var firstEndpoint = Offset(offset, size.height);
    path.arcToPoint(firstEndpoint, radius: Radius.circular(-offset), clockwise: false);

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, offset);
    path.lineTo(offset, offset);

    var secondEndPoint = Offset(0, 0);
    path.arcToPoint(secondEndPoint, radius: Radius.circular(-offset), clockwise: true);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

List<Color> _colors = [
  Color(0xFF77E4C8),
  Color(0xFFFFDA76),
  Color(0xFFFFDFD6),
  Color(0xFFE3A5C7),
  Color(0xFFB692C2),
  Color(0xFF6EACDA),
];

dynamic totalBubbles;

class CurvedListItem extends StatelessWidget {
  final Student student;
  final int index;

  CurvedListItem({required this.student,required this.index});


  @override
  Widget build(BuildContext context) {
    Color _color=_colors[(index%6)];
    if(index==totalBubbles)_color=Colors.white;
    //assign 6 unique colors to the tiles
    return Align(
      heightFactor: 0.50,
      alignment: Alignment.topCenter,
      child: ClipPath(
        clipper: CurvedRectangleClipper(),
        child: Container(
          color: _color,
          padding: EdgeInsets.only(
            left: 32,
            top: 90,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                student.name,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(height: 2),
              Text(
                student.enroll,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '${student.branch} ${student.section} ${student.year}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}

class DefaultersScreen extends StatefulWidget {
  final String assId;

  DefaultersScreen({Key? key, required this.assId}) : super(key: key);

  @override
  State<DefaultersScreen> createState() => _DefaultersScreenState();
}

class _DefaultersScreenState extends State<DefaultersScreen> {
  // dynamic defaulterStudentList;
  // dynamic studentsDoneThatAssignment;
  // dynamic allStudentsAssignment;
  final List<CurvedListItem> defaulterBubbles = [];
  bool isLoading = true;

  Future<void> initMethods() async {
    // studentsDoneThatAssignment=await AuthMethods().studentsDoneThatAssignment(widget.assId);
    // allStudentsAssignment=await AuthMethods().getClassesForAnAssignment(widget.assId);
    dynamic defaulterStudentId=await AuthMethods().defaulterStudentIds(widget.assId);
    List<Student>_defaulterStudentModel=[];
    int i=0;
    for(var v in defaulterStudentId){
      Student _student=await AuthMethods().getStudentInfo(v);
      defaulterBubbles.add(CurvedListItem(student: _student, index: i++));
    }
    // List<Student> _defaultersList = await AuthMethods().getDefaulterList(widget.assId);
    totalBubbles=defaulterBubbles.length;
    // for (Student s in _defaultersList) {
    //   CurvedListItem _ci = CurvedListItem(student: s,index: i++,);
    //   defaulterBubbles.add(_ci);
    // }
    // if(defaulterBubbles.length>=1){
    //   defaulterBubbles.add(defaulterBubbles[0]);
    // }
    setState(() {
      isLoading = false; // Update loading status once data is loaded
    });
  }

  @override
  void initState() {
    super.initState();
    initMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(5),
          child: GestureDetector(
            onTap: () async {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(3),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.brown,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        title: Text('Deadline Exceeded',style: TextStyle(color: Color(0xFFB692C2),),),
      ),
      // body: isLoading? Center(child: CircularProgressIndicator()):Text('count alloted that assign {$defaulterStudentList}'),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show a loading indicator while data is loading
          : ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: defaulterBubbles.length,
        itemBuilder: (context, index) {
          return defaulterBubbles[index];
        },
      ),
    );
  }
}

// import 'package:assignmates/database/database.dart';
// import 'package:flutter/material.dart';
// import '../models/student.dart';
//
// class CurvedRectangleClipper extends CustomClipper<Path> {
//   final double offset = 80;
//
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height - offset);
//     var firstEndpoint = Offset(offset, size.height);
//     path.arcToPoint(firstEndpoint, radius: Radius.circular(-offset), clockwise: false);
//
//     path.lineTo(size.width, size.height);
//     path.lineTo(size.width, offset);
//     path.lineTo(offset, offset);
//
//     var secondEndPoint = Offset(0, 0);
//     path.arcToPoint(secondEndPoint, radius: Radius.circular(-offset), clockwise: true);
//     path.lineTo(0, 0);
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper oldClipper) {
//     return true;
//   }
// }
//
// List<Color> _colors = [
//   Color(0xFF77E4C8),
//   Color(0xFFFFDA76),
//   Color(0xFFFFDFD6),
//   Color(0xFFE3A5C7),
//   Color(0xFFB692C2),
//   Color(0xFF6EACDA),
// ];
//
// dynamic totalBubbles;
//
// class CurvedListItem extends StatelessWidget {
//   final Student student;
//   final int index;
//
//   CurvedListItem({required this.student,required this.index});
//
//
//   @override
//   Widget build(BuildContext context) {
//     Color _color=_colors[(index%6)];
//     if(index==totalBubbles)_color=Colors.white;
//     //assign 6 unique colors to the tiles
//     return Align(
//       heightFactor: 0.50,
//       alignment: Alignment.topCenter,
//       child: ClipPath(
//         clipper: CurvedRectangleClipper(),
//         child: Container(
//           color: _color,
//           padding: EdgeInsets.only(
//             left: 32,
//             top: 90,
//             bottom: 20,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               Text(
//                 student.name,
//                 style: TextStyle(color: Colors.white, fontSize: 12),
//               ),
//               SizedBox(height: 2),
//               Text(
//                 student.enroll,
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 2),
//               Text(
//                 '${student.branch} ${student.section} ${student.year}',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20,),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class DefaultersScreen extends StatefulWidget {
//   final String assId;
//
//   DefaultersScreen({Key? key, required this.assId}) : super(key: key);
//
//   @override
//   State<DefaultersScreen> createState() => _DefaultersScreenState();
// }
//
// class _DefaultersScreenState extends State<DefaultersScreen> {
//   final List<CurvedListItem> defaulterBubbles = [];
//   bool isLoading = true;
//
//   Future<void> initMethods() async {
//     List<Student> _defaultersList = await AuthMethods().getDefaulterList(widget.assId);
//     int i=0;
//     totalBubbles=_defaultersList.length;
//     for (Student s in _defaultersList) {
//       CurvedListItem _ci = CurvedListItem(student: s,index: i++,);
//       defaulterBubbles.add(_ci);
//     }
//     if(_defaultersList.length>=1){
//       CurvedListItem _ci = CurvedListItem(student: _defaultersList[0],index: i++,);
//       defaulterBubbles.add(_ci);
//     }
//     setState(() {
//       isLoading = false; // Update loading status once data is loaded
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     initMethods();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Container(
//           margin: EdgeInsets.all(10),
//           padding: EdgeInsets.all(5),
//           child: GestureDetector(
//             onTap: () async {
//               Navigator.pop(context);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.pink.withOpacity(0.5),
//                     spreadRadius: 5,
//                     blurRadius: 7,
//                     offset: Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(3),
//                 child: Icon(
//                   Icons.arrow_back_ios,
//                   color: Colors.brown,
//                   size: 20,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         title: Text('Deadline Exceeded',style: TextStyle(color: Color(0xFFB692C2),),),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator()) // Show a loading indicator while data is loading
//           : ListView.builder(
//         padding: EdgeInsets.zero,
//         itemCount: defaulterBubbles.length,
//         itemBuilder: (context, index) {
//           return defaulterBubbles[index];
//         },
//       ),
//     );
//   }
// }
//
//
//
