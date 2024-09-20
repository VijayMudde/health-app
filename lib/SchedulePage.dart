
import 'package:amica/AddScheduleForm.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;  // Get the current user
    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddScheduleForm(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(user.uid)  // Fetch the schedules under the logged-in user's ID
            .collection('schedules')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No schedules yet', style: TextStyle(color: Colors.white)));
          }

          final schedules = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              var schedule = schedules[index];

              // Extract data safely
              String exerciseType = schedule['exerciseType'] ?? 'Unknown Exercise';
              Timestamp? date = schedule['date'] as Timestamp?;
              String time = schedule['time'] ?? 'N/A';
              bool notificationsEnabled = schedule['notificationsEnabled'] ?? false;

              // Convert Firestore Timestamp to DateTime and format it
              String formattedDate = date != null
                  ? DateFormat.yMMMd().format(date.toDate())
                  : 'N/A';

              return Card(
                color: Colors.white.withOpacity(0.1),
                child: ListTile(
                  title: Text(
                    exerciseType,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '$formattedDate at $time',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Icon(
                    notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                    color: Colors.white,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddScheduleForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
