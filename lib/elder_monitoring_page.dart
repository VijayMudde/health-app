import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ElderMonitoringPage extends StatefulWidget {
  const ElderMonitoringPage({super.key});

  @override
  _ElderMonitoringPageState createState() => _ElderMonitoringPageState();
}

class _ElderMonitoringPageState extends State<ElderMonitoringPage> {
  User? user;
  List<Map<String, dynamic>> elderList = [];
  final DatabaseReference _realtimeDatabase = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadElderData();
  }

  // Initialize the local notifications plugin
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  void _showHeartRateNotification(String elderName, int heartRate) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'elder_heart_rate_channel', // Channel ID
      'Elder Heart Rate Alerts', // Channel name
      channelDescription: 'Alerts when elder heart rate exceeds 100',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0, // Notification ID
      'Heart Rate Alert',
      '$elderName\'s heart rate is $heartRate bpm, which is above 100!',
      notificationDetails,
    );
  }

  void _showHeartRateNotificationfall(String userName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fall ',
      'fall detection ',
      channelDescription: 'Alerts when heart rate exceeds 100 bpm',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);
    await _localNotificationsPlugin.show(
      1,
      'Fall Detection ',
      '$userName has fallen ',
      notificationDetails,
    );
  }

  void _loadElderData() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot eldersSnapshot = await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('elders')
            .get();

        for (var doc in eldersSnapshot.docs) {
          var elderData = doc.data() as Map<String, dynamic>;
          elderList.add(elderData);

          // Now we call the Firebase Realtime Database to get heart rate and fall detection data
          final elderName = elderData['name'] ?? '';
          if (elderName.isNotEmpty) {
            _realtimeDatabase
                .child('users')
                .child(elderName)
                .child('stats')
                .onValue
                .listen((event) {
              final data = event.snapshot.value as Map<dynamic, dynamic>?;
              if (data != null) {
                setState(() {
                  elderData['heartRate'] = data['heartRate'] ?? 'N/A';
                  elderData['predicate'] = data['predicate'] ?? 'N/A';
                });
                if (elderData['predicate'] == 'fall') {
                  _showHeartRateNotificationfall(elderData['name'] ?? 'Elder');
                }

                // Check if heart rate exceeds 100 and send notification
                if (int.tryParse(elderData['heartRate'] ?? '') != null &&
                    int.parse(elderData['heartRate'] ?? '') > 100) {
                  _showHeartRateNotification(
                      elderData['name'] ?? 'Elder', int.parse(elderData['heartRate']));
                }

                print('Updated elder data: $elderData');
              }
            });
          }
        }

        setState(() {});
      }
    } catch (e) {
      print('Error loading elder data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Elder Monitoring'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Elder Monitoring',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            if (elderList.isNotEmpty) ...[
              for (var elder in elderList)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      elder['name'] ?? 'Unknown Elder',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.directions_walk,
                            color: Colors.white),
                        title: const Text(
                          'Current status',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          '${elder['predicate'] ?? 'N/A'}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading:
                        const Icon(Icons.favorite, color: Colors.white),
                        title: const Text(
                          'Heart Rate',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${elder['heartRate'] ?? 'N/A'} bpm',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            const SizedBox(width: 10),
                            if (int.tryParse(elder['heartRate'] ?? '') != null &&
                                int.parse(elder['heartRate'] ?? '') > 100)
                              const Icon(Icons.monitor_heart,
                                  color: Colors.red),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
            ] else ...[
              const Text(
                'No elder members to monitor.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
