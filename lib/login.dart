import 'package:flutter/material.dart';
import 'package:project20183227/home.dart';
import 'package:project20183227/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController idin = TextEditingController();
  TextEditingController pwin = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log in'),
        elevation: 0.0,
        backgroundColor: Colors.lightBlueAccent.shade100,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 40)),
              Text('오늘 하루 어땠니?',
              style: TextStyle(
                fontSize: 35.0,
              ),),
              Padding(padding: EdgeInsets.only(top: 40)),
              Center(
                child: Image.asset('asset/cat.png', width: 200.0,),
              ),
              Form(
                  child: Theme(
                data: ThemeData(
                    primaryColor: Colors.grey,
                    inputDecorationTheme: InputDecorationTheme(
                        labelStyle:
                            TextStyle(color: Colors.teal, fontSize: 15.0))),
                child: Container(
                    padding: EdgeInsets.all(40.0),
                    child: Builder(builder: (context) {
                      return Column(
                        children: [
                          TextField(
                            controller: idin,
                            autofocus: true,
                            decoration: InputDecoration(labelText: 'E-mail을 입력하세요'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          TextField(
                            controller: pwin,
                            decoration:
                                InputDecoration(labelText: '비밀번호를 입력하세요'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),

                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                                onPressed: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              signup()));
                                },
                                child: Text("SignUp")),
                          ),
                          ButtonTheme(
                              minWidth: 100.0,
                              height: 50.0,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if(idin.text.isEmpty || pwin.text.isEmpty)return;
                                  try{
                                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                                      email: idin.text.toLowerCase().trim(),
                                      password: pwin.text.trim(),
                                    );
                                    showSnackBar(context, Text('로그인 성공'));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                DiaryList(user: FirebaseAuth.instance.currentUser)));
                                  }
                                  on FirebaseAuthException catch (e){
                                    showSnackBar(context, Text('error $e'));
                                  }
                                },
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 35.0,
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlueAccent.shade200),
                              ))
                        ],
                      );
                    })),
              ))
            ],
          ),
        ),
      ),
    );
  }
}

void showSnackBar(BuildContext context, Text text) {
  final snackBar = SnackBar(
    content: text,
    backgroundColor: Color.fromARGB(255, 112, 48, 48),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

