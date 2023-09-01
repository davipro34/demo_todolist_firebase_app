import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() => runApp(const InitializeApp());

class InitializeApp extends StatelessWidget {
  const InitializeApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const ErrorFirebase();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return const Loading();
      },
    );
  }
}

class ErrorFirebase extends StatelessWidget {
  const ErrorFirebase({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: const Center(
            child: Text('Erreur de chargement des données'),
          ),
        ),  
      ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: const Center(
            child: Text('Chargement'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final databaseReference = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Todolist Firebase'),
          backgroundColor: Colors.blue, 
        ),
        body: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  addDataToFirebase();
                },
                child: const Text('Ajouter des données'),
              ),
            ),
            Expanded(
              child: ListSection(),
            ),
          ],
        ),
      ),
    );
  }

  void addDataToFirebase() {
    try {
      databaseReference.collection("collectionItems").add({
        "text": "Lire un livre pendant 30 minutes",
      }).then((value) {
        print(value.id);
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

class ListSection extends StatelessWidget {
  ListSection({super.key});
  final databaseReference = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: databaseReference.collection('collectionItems').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return const Text('Loading...');
        return ListView(
          children: snapshot.data!.docs.map((document) {
            return ListTile(
              title: Text(document['text']),
            );
          }).toList(),  
        );
      }
    );
  }
}

void addItem() {
  try {
    var now = new DateTime.now();
    var hourAndMinutes = new DateFormat('HH:mm');
    databaseReference.collection("collectionItems").add({
      "text": myController.text,
      "time": hourAndMinutes.format(now),
    }).then((value) {
      print(value.id);
      myController.clear();
    });
  } catch (e) {
    print(e.toString());
  }
}