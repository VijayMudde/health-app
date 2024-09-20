
import 'package:amica/AddRoomForm.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 // Import the AddRoomForm

class RoomPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddRoomForm(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No rooms available',
                  style: TextStyle(color: Colors.white)),
            );
          }

          final rooms = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              var room = rooms[index];
              return Card(
                child: ListTile(
                  title: Text(room['name'],
                      style: TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room['description'],
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 8.0),  // Add spacing
                      SelectableText(
                        room['url'] ?? 'No URL provided',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.link, color: Colors.blue),
                    onPressed: () {
                      // You can still use _openRoomURL if needed
                      //_openRoomURL(room['url']);
                    },
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
              builder: (context) => AddRoomForm(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
