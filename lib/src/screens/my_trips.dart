import 'package:flutter/material.dart';
import '../models/my_trips_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';

List _mytrips;

class MyTrips extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyTripDetails();
  }
}

class MyTripDetails extends State<MyTrips> {
  final List<int> stars = [1, 2, 3, 4, 5];
  bool _progressBarActive = true;
  void myTripList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _mytrips = await myTrips(prefs.getInt('id').toString());
    setState(() {
      _progressBarActive = false;
    });
  }

  @override
  void initState() {
    setState(() {
      _progressBarActive = true;
      myTripList();
    });
    super.initState();
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      // _progressBarActive = true;
      myTripList();
    });
    return null;
  }

  Widget _singleListItem(BuildContext context, int index) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0),
      child: Column(
        children: <Widget>[
          rowContainer(stars, 'assets/profile.png', index, context),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Icon(Icons.check_circle,color: Colors.green,),
                //  Icon(Icons.sync,color: Colors.orangeAccent),
                SizedBox(
                  width: 55.00,
                ),
                _mytrips[index]['status'] != 'incomplete'
                    ? statusChip(Icons.check_circle, Colors.green, 'Completed')
                    : statusChip(Icons.sync, Colors.orangeAccent, 'Scheduled'),
                _mytrips[index]['status'] != 'incomplete'
                    ? shareButtonDisable()
                    : shareButtonEnable(index),
                    
              ]),
        ],
      ),
    );
  }

  Widget build(context) {
    return Scaffold(
        backgroundColor: Colors.orange[100],
        appBar: AppBar(
          iconTheme: IconTheme.of(context),
          centerTitle: true,
          title: Text(
            'My Trips',
            style: TextStyle(color: Colors.white, fontSize: 21.0),
          ),
        ),
        body: _progressBarActive
            ? noDataYet()
            : (_mytrips.length == 0 ? noTrip() : listBuilder()));
  }

  Widget listBuilder() {
    return RefreshIndicator(
      child: ListView.builder(
        itemBuilder: _singleListItem,
        itemCount: _mytrips.length,

        // children: [
        //   Column(
        //     children: drivers
        //         .map((element) => Card(
        //               color: Colors.white,
        //               margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0),
        //               child: Column(
        //                 children: <Widget>[
        //                   rowContainer(element),
        //                   Image.asset(
        //                     'assets/car.jpg',
        //                   ),
        //                   Icon(
        //                     Icons.star,
        //                     color: Colors.yellow,
        //                   ),
        //                 ],
        //               ),
        //             ))
        //         .toList(),
        //   ),
        // ],
      ),
      onRefresh: refreshList,
    );
  }

  Widget noDataYet() {
    return Center(
      child: _dataProcessing(context),
    );
  }
}

Widget rowContainer(
    List<int> stars, String image, int index, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.centerLeft,
          colors: [Colors.orange[400], Colors.white]),
    ),
    margin: EdgeInsets.fromLTRB(6.0, 4.0, 0.0, 1.0),
    child: ExpansionTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          avatar(image),
          Container(margin: EdgeInsets.only(left: 10.00)),
          avatarText(_mytrips[index]['driver_name'],
              _mytrips[index]['driver_cabNumber']),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: stars
                .map(
                  (element) => Icon(
                    Icons.star,
                    // size:10.00,
                    color: Colors.yellowAccent,
                  ),
                )
                .toList(),
          ),
          Spacer(
            flex: 4,
          ),
          // avatarMore(index, context),
        ],
      ),
      children: <Widget>[
        dataChips(
            'DESTINATION : ', _mytrips[index]['bookingAddressTo'], Icons.place),
        dataChips('ORIGIN : ', _mytrips[index]['bookingAddressFrom'],
            Icons.trip_origin),
        dataChips('CONTACT : ', _mytrips[index]['bookingPhone'].toString(),
            Icons.contact_phone),
        dataChips('NAME : ', _mytrips[index]['user_userName'], Icons.person),
        dataChips('DATE : ', _mytrips[index]['date'], Icons.date_range),
        dataChips('TIME : ', _mytrips[index]['time'], Icons.timer),
      ],
    ),
  );
}

Widget avatar(String image) {
  return CircleAvatar(
    radius: 30.0,
    // backgroundImage: NetworkImage('https://via.placeholder.com/150'),
    backgroundImage: AssetImage(image),
    backgroundColor: Colors.black12,
    // child: Text(
    //   'Test',
    //   style: TextStyle(color: Colors.white, fontSize: 12.0),
    // ),
  );
}

Widget avatarText(String name, String number) {
  return Column(
    children: <Widget>[
      Text(
        name.toUpperCase(),
        style: TextStyle(
            color: Colors.orange, fontSize: 15.0, fontWeight: FontWeight.w600),
      ),
      Text(
        number,
        style: TextStyle(color: Colors.orange[400], fontSize: 12.0),
      ),
    ],
  );
}

Widget avatarMore(int index, BuildContext context) {
  return IconButton(
    icon: Icon(Icons.arrow_right),
    tooltip: 'Know More',
    iconSize: 35.0,
    color: Colors.white,
    onPressed: () =>
        Navigator.pushNamed(context, '/driver/' + index.toString()),
  );
}

Widget dataChips(String label, String data, dynamic icon) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
          begin: FractionalOffset(0.0, 0.8),
          end: FractionalOffset(0.0, 0.4),
          colors: [Colors.white, Colors.orange[100]]),
    ),
    padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Row(
            children: <Widget>[
              SizedBox(width: 12.0),
              Icon(
                icon,
                color: Colors.orangeAccent,
                size: 25.0,
              ),
              SizedBox(width: 8.0),
              Text(
                label,
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600]),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            data,
            style: TextStyle(
                fontSize: 16.0,
                // fontWeight: FontWeight.bold,
                color: Colors.orange[700]),
          ),
        ),
        SizedBox(
          height: 51.0,
        ),
      ],
    ),
  );
}

Widget statusChip(dynamic icon, dynamic color, String text) {
  return Chip(
    padding: EdgeInsets.all(0.0),
    backgroundColor: Colors.white,
    avatar: Icon(
      icon,
      color: color,
    ),
    label: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    ),
  );
}

Widget noTrip() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.sentiment_very_dissatisfied,
            color: Colors.white, size: 65.0),
        Text(
          'You have not booked any Cab \n Book a Cab and enjoy our services...',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget _dataProcessing(BuildContext context) {
  return AlertDialog(
    contentPadding: EdgeInsets.all(0.0),
    elevation: 0.0,
    backgroundColor: Colors.transparent,
    content: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

// Chip(
//   backgroundColor: Colors.white,
//   shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//           topRight: Radius.circular(20),
//           bottomRight: Radius.circular(20))),
//   avatar: Icon(
//     icon,
//     color: Colors.orange,
//   ),
//   label: RichText(
//     text: TextSpan(
//       children: <TextSpan>[
//         TextSpan(
//             text: label,
//             style: TextStyle(
//                 fontWeight: FontWeight.bold, color: Colors.orange)),
//         TextSpan(
//           text: data,
//           style: TextStyle(color: Colors.orange[400]),
//         ),
//       ],
//     ),
//   ),
// )
Widget shareButtonEnable(int index) {
  return
  Container(
    padding: EdgeInsets.only(right:4.0),
    child: FloatingActionButton(
    shape: _DiamondBorder(),
    mini: true,
    onPressed: () {
      Share.share(_mytrips[index]['bookingName'] +
              ' ' +
              'is going to' +
              ' ' +
              _mytrips[index]['bookingAddressTo'] +
              '\nJoin' +
              ' ' +
              _mytrips[index]['bookingName'] +
              ' ' +
              'on' +
              ' ' +
              _mytrips[index]['date'] +
              '\nFor more info contact' +
              ' ' +
              _mytrips[index]['bookingName'] +
              ' ' +
              'on' +
              ' ' +
              _mytrips[index]['bookingPhone'].toString() +
              ' ' +
              'and install RIDEz\n' +
              'https://www.dropbox.com/s/8iireeb52o4tmkt/RIDEz.apk?dl=0'
          // 'DOWNLOAD THE RIDEz APP...\n"Joyfull and Comfortable travel" \nhttps://example.com'
          
          );
    },
    child: Icon(
      Icons.share,
      color: Colors.white,
      size: 15.00,
    ),
    backgroundColor: Colors.orange,
  ),
  );
}

Widget shareButtonDisable() {
  return FloatingActionButton(
    shape: _DiamondBorder(),
    mini: true,
    onPressed: () {
      // Add your onPressed code here!
    },
    child: Icon(
      Icons.share,
      color: Colors.white,
      size: 15.00,
    ),
    backgroundColor: Colors.grey,
  );
}

class _DiamondBorder extends ShapeBorder {
  const _DiamondBorder();

  @override
  EdgeInsetsGeometry get dimensions {
    return const EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..moveTo(rect.left + rect.width / 2.0, rect.top)
      ..lineTo(rect.right, rect.top + rect.height / 2.0)
      ..lineTo(rect.left + rect.width / 2.0, rect.bottom)
      ..lineTo(rect.left, rect.top + rect.height / 2.0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {}

  // This border doesn't support scaling.
  @override
  ShapeBorder scale(double t) {
    return null;
  }
}
