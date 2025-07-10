import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reviw/screens/home_screen.dart';
import 'screens/login_screen.dart';


void main()async
{
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     options: FirebaseOptions(

apiKey: "AIzaSyDGU-jXUMbzsTMgw8tYZM0Z06G4gQ8GCoc",
    authDomain: "dbclient-fc5bb.firebaseapp.com",
    projectId: "dbclient-fc5bb",
 storageBucket: "dbclient-fc5bb.appspot.com", 
    messagingSenderId: "1024097477667",
    appId: "1:1024097477667:web:96ffec4736171ac121bd96",
    measurementId: "G-79ZTW32994"
  )
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic Review',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
} 