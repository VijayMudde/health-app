import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _elderNameController = TextEditingController();
  final _elderIdController = TextEditingController();

  void _addElderProfile() async {
    final name = _elderNameController.text;
    final id = _elderIdController.text;

    if (name.isNotEmpty && id.isNotEmpty) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('elders')
            .doc(id)
            .set({
          'name': name,
          'id' : id,


        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Elder added successfully')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _elderNameController,
              decoration: InputDecoration(labelText: 'Elder Name'),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: _elderIdController,
              decoration: InputDecoration(labelText: 'Elder ID'),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: _addElderProfile,
              child: Text('Add Elder'),
            ),
          ],
        ),
      ),
    );
  }
}
