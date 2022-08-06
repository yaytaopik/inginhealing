import 'package:flutter/material.dart';
import 'package:inginhealing/service/service_location.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HomeBottomSheet extends StatefulWidget {
  const HomeBottomSheet({Key? key}) : super(key: key);

  @override
  State<HomeBottomSheet> createState() => _HomeBottomSheetState();
}

class _HomeBottomSheetState extends State<HomeBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ServiceLocation>(
            create: (context) => ServiceLocation()),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            // Handlebar
            height: 5.0,
            width: 50.0,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          SizedBox(height: 20),
          Column(
            children: <Widget>[
              Text('Lokasi saat ini:'),
              SizedBox(height: 10),
              Container(
                child: Consumer<ServiceLocation>(
                    builder: (context, sLocation, child) {
                  if (sLocation.myAddress == 'Loading..') {
                    sLocation.getLocation();
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Text(
                      sLocation.myAddress.toUpperCase(),
                      style: TextStyle(fontSize: 17),
                      textAlign: TextAlign.center,
                    );
                  }
                }),
              ),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ],
      ),
    );
  }
}
