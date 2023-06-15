import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project20183227/firebase_options.dart';
import 'package:project20183227/login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      FocusScope.of(context).unfocus();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LogIn()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.shade100,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(padding: EdgeInsets.only(top: 50)),
                Text(
                  '오늘 하루 어땠니?',
                  style: TextStyle(
                    fontSize: 35.0,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 50)),
                Center(
                  child: Image.asset(
                    'asset/cat.png',
                    width: 200.0,
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 50)),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
