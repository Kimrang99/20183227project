import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project20183227/login.dart';

class signup extends StatefulWidget {
  @override
  State<signup> createState() => _SignUpState();
}

class _SignUpState extends State<signup> {
  TextEditingController idinput = TextEditingController();
  TextEditingController pwinput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
        backgroundColor: Colors.lightBlueAccent.shade100,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                            controller: idinput,
                            autofocus: true,
                            decoration: InputDecoration(labelText: 'E-mail을 입력하세요'),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          TextField(
                            controller: pwinput,
                            decoration: InputDecoration(labelText: '비밀번호를 입력하세요'),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if(idinput.text.isEmpty || pwinput.text.isEmpty)return;
                              try{
                                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                    email: idinput.text.toLowerCase().trim(),
                                    password: pwinput.text.trim(),
                                );
                                //print('회원가입 성공');
                                showSnackBar(context, Text('회원가입 성공'));
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            LogIn()));
                              }
                              on FirebaseAuthException catch (e){
                                //print('error $e');
                                showSnackBar(context, Text('error $e'));
                              }
                            },
                            child: Text('회원가입'),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
