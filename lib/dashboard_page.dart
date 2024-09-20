import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/link.dart';
import 'elder_monitoring_page.dart'; // Import the new page
import 'package:permission_handler/permission_handler.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  User? user;
  Map<String, dynamic>? userData;
  final DatabaseReference _realtimeDatabase = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestNotificationPermission();
    _loadUserData();
  }

  // Request notification permission
  void _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Initialize the local notifications plugin
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  // Show notification for heart rate exceeding threshold
  void _showHeartRateNotification(String userName, int heartRate) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'heart_rate_channel',
      'Heart Rate Alerts',
      channelDescription: 'Alerts when heart rate exceeds 100 bpm',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);
    await _localNotificationsPlugin.show(
      0,
      'Heart Rate Alert',
      '$userName\'s heart rate is $heartRate bpm, which is above 100!',
      notificationDetails,
    );
  }

  void _showHeartRateNotificationfall(String userName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fall',
      'Fall Detection',
      channelDescription: 'Alerts when a fall is detected',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);
    await _localNotificationsPlugin.show(
      1,
      'Fall Detection',
      '$userName has fallen.',
      notificationDetails,
    );
  }

  // Load user data and monitor for health stats
  void _loadUserData() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user details from Firestore
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user!.uid).get();

        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
        });

        // Fetch heart rate, and predicate from Realtime Database
        _realtimeDatabase
            .child('users')
            .child(userData?['userName'] ?? '')
            .child('stats')
            .onValue
            .listen((event) {
          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          setState(() {
            userData?['heartRate'] = data?['heartRate'] ?? 'N/A';
            userData?['predicate'] = data?['predicate'] ?? 'N/A';
          });
          if (userData?['predicate'] == 'fall') {
            _showHeartRateNotificationfall(userData?['userName'] ?? 'User');
          }

          // Trigger notification if heart rate exceeds threshold
          if (int.tryParse(userData?['heartRate'] ?? '') != null &&
              int.parse(userData?['heartRate'] ?? '') > 100) {
            _showHeartRateNotification(userData?['userName'] ?? 'User',
                int.parse(userData?['heartRate'] ?? '0'));
          }
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color for better contrast
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.monitor_heart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ElderMonitoringPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            Text(
              'Welcome, ${userData?['userName'] ?? 'User'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Display User Details
            if (userData != null) ...[
              Text('Age: ${userData?['age'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white)),
              Text('Gender: ${userData?['gender'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white)),
              Text('Place: ${userData?['place'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white)),
            ],
            const SizedBox(height: 20),
            // Stats Section
            const Text(
              'Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            // Display Predicate (Fall Detection)
            if (userData != null) ...[
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.white),
                  title: const Text('Current status',
                      style: TextStyle(color: Colors.white)),
                  trailing: Text(
                    '${userData?['predicate'] ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Display Heart Rate
              Card(
                color: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.white),
                  title: const Text('Heart Rate', style: TextStyle(color: Colors.white)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${userData?['heartRate'] ?? 'N/A'} bpm',
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      const SizedBox(width: 10),
                      if (int.tryParse(userData?['heartRate'] ?? '') != null &&
                          int.parse(userData?['heartRate'] ?? '') > 100)
                        const Icon(Icons.monitor_heart, color: Colors.red),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Quick Actions Section
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Center(
                    child: Link(
                      target: LinkTarget.self,
                      uri: Uri.parse(
                          'https://ephemeral-dodol-320707.netlify.app/'),
                      builder: (context, followLink) => ElevatedButton(
                        child: const Text('Get Yoga Assistance'),
                        onPressed: followLink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildQuickActionButton(
                    'Health Monitoring',
                    Icons.health_and_safety,
                        () {
                      Navigator.pushNamed(context, '/health');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
      String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
