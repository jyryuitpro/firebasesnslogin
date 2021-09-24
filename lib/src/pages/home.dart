import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasesnslogin/src/pages/login.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase SNS Login'),
      ),
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (!snapshot.hasData) {
            return Login();
          } else {
            print('===== snapshot: $snapshot =====');
            print('===== snapshot.data: ${snapshot.data} =====');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${snapshot.data!.displayName ?? snapshot.data!.email}님 환영합니다.'),
                  FlatButton(
                    color: Colors.grey.withOpacity(0.3),
                    child: Text('Logout'),
                    onPressed: FirebaseAuth.instance.signOut,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
