import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:budget/models/Trip.dart';

import 'package:budget/widgets/provider_widget.dart';

// new
import 'package:budget/models/Trip.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budget/widgets/provider_widget.dart';

class HomeView extends StatefulWidget {
  final Trip trip;

  HomeView({Key key, @required this.trip}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  TextEditingController _budgetController = TextEditingController();
  var _budget;

  /*
  void initState() {
    super.initState();

    _budgetController.text = widget.trip.budget.toStringAsFixed(0);
    _budget = widget.trip.budget.floor();
  }
  */

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
          stream: getUsersTripsStreamSnapshots(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            return new ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (BuildContext context, int index) => buildTripCard(
                context,
                snapshot.data.documents[index],
              ),
            );
          }),
    );
  }

  Stream<QuerySnapshot> getUsersTripsStreamSnapshots(
      BuildContext context) async* {
    final uid = await Provider.of(context).auth.getCurrentUID();
    yield* Firestore.instance
        .collection('userData')
        .document(uid)
        .collection('trips')
        .snapshots();
  }

  Widget buildTripCard(BuildContext context, DocumentSnapshot trip) {
    return new Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      trip['title'],
                      style: new TextStyle(fontSize: 30.0),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteTrip(context);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 80.0),
                child: Row(children: <Widget>[
                  Text(
                      "${DateFormat('dd/MM/yyyy').format(trip['startDate'].toDate()).toString()} - ${DateFormat('dd/MM/yyyy').format(trip['endDate'].toDate()).toString()}"),
                  Spacer(),
                ]),
              ),
              /*
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "\$${(trip['budget'] == null) ? "n/a" : trip['budget'].toStringAsFixed(2)}",
                      style: new TextStyle(fontSize: 35.0),
                    ),
                    Spacer(),
                    Icon(Icons.directions_car),
                  ],
                ),
              )*/
            ],
          ),
        ),
      ),
    );
  }

  Future deleteTrip(context) async {
    var uid = await Provider.of(context).auth.getCurrentUID();
    final doc = Firestore.instance
        .collection('userData')
        .document(uid)
        .collection("trips")
        .document(widget.trip.documentId);

    return await doc.delete();
  }

  Future updateTrip(context) async {
    var uid = await Provider.of(context).auth.getCurrentUID();
    final doc = Firestore.instance
        .collection('userData')
        .document(uid)
        .collection("trips")
        .document(widget.trip.documentId);

    return await doc.setData(widget.trip.toJson());
  }
}
