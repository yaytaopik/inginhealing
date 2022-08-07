import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:inginhealing/service/read_data.dart';

class ViewData extends StatefulWidget {
  const ViewData({Key? key}) : super(key: key);
  @override
  State<ViewData> createState() => _ViewDataState();
}

class _ViewDataState extends State<ViewData> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  final Stream<QuerySnapshot> dataHealing =
      FirebaseFirestore.instance.collection('datahealing').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rencana healing'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: dataHealing,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('snapshot error');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading..');
                }

                final data = snapshot.requireData;

                return ListView.builder(
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    // return Text('${data.docs[index]['judul']}');
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                '${data.docs[index]['judul']}',
                                style: TextStyle(fontSize: 20),
                              ),
                              subtitle: Text(
                                '${data.docs[index]['detail']}',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  'Tujuan: ${data.docs[index]['kemana']}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                TextButton(
                                  child: const Text('Hapus'),
                                  onPressed: () async {
                                    deleteData(snapshot.data?.docs[index].id);
                                  },
                                ),
                              ],
                            )
                            // // Text('Healing ke:')
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void deleteData(id) {
    FirebaseFirestore.instance.collection("datahealing").doc(id).delete();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Data dihapus'),
              content: Text('Data telah dihapus'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('OK'))
              ],
            ));
  }
}
