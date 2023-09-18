import 'package:flutter/material.dart';
import '../models/my_trips_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/location_widget.dart';
import '../models/location_model.dart';
import '../models/booking_model.dart';

List _mytrips;
bool _progressBarActive = false;
bool _floatProgressBarActive = false;

class Dashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DriverDashboard();
  }
}

class DriverDashboard extends State<Dashboard> {
  void rideDone(BuildContext context, int index) async {
    LocationData getLocationDetails = await getUserLocation();
    String currentLocation;
    if (getLocationDetails.origin != '') {
      currentLocation = getLocationDetails.origin;
    } else {
      currentLocation = _mytrips[index]['bookingAddressTo'];
    }

    final BookingModel bookingModel = BookingModel();
    final Map<String, dynamic> msg = await bookingModel.updateBooking(
        _mytrips[index]['id'].toString(),
        _mytrips[index]['driverAssignedId'].toString(),
        currentLocation);

    if (!msg['error']) {
      Navigator.pushReplacementNamed(context, '/driverDashboard');
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialog(
                context, msg['message'], msg['error']); //function defination
          });
    } else {
      print(msg['message']);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialog(
                context, msg['message'], msg['error']); //function defination
          });
    }

    setState(() {
      _progressBarActive = false;
    });
  }

   void updateLocation(BuildContext context) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
    LocationData getLocationDetails = await getUserLocation();
    String currentLocation;
    if (getLocationDetails.origin != '') {
      currentLocation = getLocationDetails.origin;
    } else {
      currentLocation = 'Jammu & Kashmir';
    }

    final BookingModel bookingModel = BookingModel();
    final Map<String, dynamic> msg = await bookingModel.updateLocation(
        prefs.getInt('id').toString(),
        currentLocation);

    if (!msg['error']) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialog(
                context, msg['message'], msg['error']); //function defination
          });
    } else {
      print(msg['message']);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialog(
                context, msg['message'], msg['error']); //function defination
          });
    }

    setState(() {
      _floatProgressBarActive = false;
    });
  }

  void myTripList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _mytrips = await mybookings(prefs.getInt('id').toString());
    setState(() {
      _progressBarActive = false;
    });
  }

  Widget rideCompleted(int index) {
    return _mytrips[index]['status'] == 'complete'
        ? Container()
        : RaisedButton(
            textColor: Colors.white,
            padding: EdgeInsets.all(0.0),
            onPressed: () {
              setState(() {
                _progressBarActive = true;
                rideDone(context, index);
              });
            },
            shape: StadiumBorder(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                gradient: LinearGradient(
                  begin: FractionalOffset(0.9, 0.5),
                  end: FractionalOffset(0.0, 0.0),
                  colors: <Color>[
                    Color(0xFFFFFB74D),
                    Colors.white,
                    // Colors.orange
                  ],
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 9.9),
              child: Container(
                padding: EdgeInsets.only(left: 25.00),
                child: Text(
                  'TRIP COMPLETED',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
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
      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 7.0),
      child: Column(
        children: <Widget>[
          // SizedBox(height: 5.00,),
          rowContainer('assets/profile.png', index, context),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            _progressBarActive
                ? _dataProcessing(context)
                : rideCompleted(index),
          ]),
        ],
      ),
    );
  }

  Widget build(context) {
    return Scaffold(
        backgroundColor: Colors.orange[100],
        appBar: AppBar(
          leading: IconButton(
            padding: EdgeInsets.only(left: 20.00),
            icon: Icon(Icons.power_settings_new),
            onPressed: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              prefs.clear();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (Route<dynamic> route) => false);
            },
          ),
          iconTheme: IconTheme.of(context),
          centerTitle: true,
          title: Text(
            'Dashboard',
            style: TextStyle(color: Colors.white, fontSize: 21.0),
          ),
          actions: <Widget>[
            // action button
            IconButton(
              padding: EdgeInsets.only(right: 5.00),
              icon: Icon(Icons.notifications),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
          ],
        ),
        body: _progressBarActive
            ? noDataYet()
            : (_mytrips.length == 0 ? noTrip() : listBuilder()),
            floatingActionButton: _floatProgressBarActive?_dataProcessing(context):FloatingActionButton(
      onPressed: () {
        setState(() {
                 _floatProgressBarActive = true;
                updateLocation(context);
               });
      },
      child: Icon(Icons.my_location,
      color: Colors.white,
      // size: 30.0,
      ),
      backgroundColor: Colors.orange,
    ),
            );
  }

  Widget listBuilder() {
    return RefreshIndicator(
      child: ListView.builder(
        itemBuilder: _singleListItem,
        itemCount: _mytrips.length,
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

Widget rowContainer(String image, int index, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.centerLeft,
          colors: [Colors.orange[400], Colors.white]),
    ),
    margin: EdgeInsets.fromLTRB(6.0, 4.0, 0.0, 0.0),
    child: ExpansionTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          avatar(image),
          Container(margin: EdgeInsets.only(left: 10.00)),
          avatarText(_mytrips[index]['driver_name'],
              _mytrips[index]['driver_cabNumber']),
          // SizedBox(width: 0.00),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _mytrips[index]['status'] != 'incomplete'
                  ? statusChip(Icons.check_circle, Colors.green, 'Completed')
                  : statusChip(Icons.sync, Colors.orangeAccent, 'Scheduled'),
            ],
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
        dataChips('NAME : ', _mytrips[index]['bookingName'], Icons.person),
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
    padding: EdgeInsets.fromLTRB(10.00, 0.00, 20.00, 0.00),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
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

Widget alertDialog(BuildContext context, String message, bool error) {
  return AlertDialog(
    backgroundColor: Colors.orange.withOpacity(0.5),
    title: error
        ? Icon(Icons.sentiment_dissatisfied, size: 60.0)
        : Icon(Icons.sentiment_very_satisfied, size: 60.0),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(error ? 'Please try again later...' : 'Voila!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 25.0)),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 17.0, fontWeight: FontWeight.bold),
        ),
      ],
    ),
    actions: <Widget>[
      FlatButton(
        child: Text('OK', style: TextStyle(color: Colors.white)),
        onPressed: () {
          if (!error) {
            Navigator.pop(context);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    ],
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
          'No bookings Available yet \n Stay tuned...',
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
