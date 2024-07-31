import 'package:flutter/material.dart';


class DefaultersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
      title: 'Overdue assignments',
    );
  }
}

class CurvedRectangleClipper extends CustomClipper<Path> {
  final double offset = 80;
  @override
  Path getClip(Size size) {
    // TODO: implement getClip
    Path path = Path();
    path.lineTo(0, size.height - offset);
    var firstEndpoint = Offset(offset, size.height);
    path.arcToPoint(firstEndpoint, radius: Radius.circular(-offset),clockwise: false);

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, offset);
    path.lineTo(offset, offset);

    var secondEndPoint = Offset(0,0);

    path.arcToPoint(secondEndPoint, radius: Radius.circular(-offset),clockwise: true);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
List<Color>_color=[Color(0xFFFFDFD6),Color(0xFFE3A5C7),Color(0xFFB692C2),Color(0xFF6EACDA),Color(0xFF77E4C8),Color(0xFFFFDA76)];
class CurvedListItem extends StatelessWidget {
  final String title;
  final String time;
  final String people;
  final IconData icon;

  CurvedListItem({required this.title, required this.time, required this.icon,required this.people});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedRectangleClipper(),
      child: Container(
        color: Colors.pink,
        padding: EdgeInsets.only(
          left: 32,
          top: 100,
          bottom: 50,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                time,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              Row(),
            ]),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(5),
          child: GestureDetector(
            onTap: (){
              //cant use pop-context bcox u came from push and removed until
              Navigator.pop(context);
            },
            child: Container(decoration:BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),child: Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.arrow_back_ios,color: Colors.brown,size: 20,)),),
          ),
        ),
        title: Text('Overdue Assignments'),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          CurvedListItem(
              title: 'Yoga and Meditation for Beginners',
              time: 'TODAY 5:30 PM', icon: Icons.add, people: 'me',),
          // CurvedListItem(
          //   title: 'Practice French, English And Chinese',
          //   time: 'TUESDAY 5:30 PM',
          // ),
          // CurvedListItem(
          //   title: 'Adobe XD Live Event in Europe',
          //   time: 'FRIDAY 6:00 PM',
          // ),
        ],
      ),
    );
  }
}

