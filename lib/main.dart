
import 'package:amica/constapi.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:permission_handler/permission_handler.dart'; // Import permission handler
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import notifications

import 'login_page.dart';
import 'exercise_page.dart';
import 'health_monitoring_page.dart';
import 'home_page.dart';

// Initialize notifications
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Gemini API
  Gemini.init(apiKey: GEMINI_API_KEY);

  // Initialize notification plugin
  await initializeNotifications();

  runApp(MyApp());
}

// Initialize notifications
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    requestNotificationPermission(); // Request notification permission on app startup
  }

  // Request notification permissions for Android 13+ and handle other permissions
  Future<void> requestNotificationPermission() async {
    // Check if notification permission is already granted
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      // If denied, request permission
      PermissionStatus newStatus = await Permission.notification.request();
      
      if (newStatus.isGranted) {
        print('Notification permission granted');
      } else if (newStatus.isPermanentlyDenied) {
        // Handle the case where the permission is permanently denied
        print('Notification permission permanently denied. Please enable it in settings.');
        openAppSettings();
      }
    } else if (status.isGranted) {
      print('Notification permission already granted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TechnoTeam App',
      theme: ThemeData(
        brightness: Brightness.dark, // Set to dark or light as per your design
        primaryColor: hextStringToColor("5E61F4"),
        scaffoldBackgroundColor: hextStringToColor("CB2B93"),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: hextStringToColor("5E61F4"),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: AuthWrapper(),
      routes: {
        '/exercise': (context) => ExercisePage(),
        '/health': (context) => HealthMonitoringPage(),
      },
    );
  }

  // Utility function to convert HEX color to Flutter color
  Color hextStringToColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor; // Add opacity if not provided
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Something went wrong: ${snapshot.error}'),
              ),
            );
          }
          if (snapshot.hasData) {
            // User is logged in
            return HomePage();
          } else {
            // User is not logged in
            return LoginPage();
          }
        }
        // Show loading indicator while checking auth state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
