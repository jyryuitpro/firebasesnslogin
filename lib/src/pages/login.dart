import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    bool isAvailable = await SignInWithApple.isAvailable();
    if (isAvailable) {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'com.anomalo.dev.snslogin.firebasesnslogin.web',
          redirectUri: Uri.parse(
              'https://silken-whispering-porpoise.glitch.me/callbacks/sign_in_with_apple'),
        ),
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    } else {
      final clientState = Uuid().v4();
      final url = Uri.https('appleid.apple.com', '/auth/authorize', {
        'response_type': 'code id_token',
        'client_id': "com.anomalo.dev.snslogin.firebasesnslogin.web",
        'response_mode': 'form_post',
        'redirect_uri':
            'https://silken-whispering-porpoise.glitch.me/callbacks/apple/sign_in_with_apple',
        'scope': 'email name',
        'state': clientState,
      });

      final result = await FlutterWebAuth.authenticate(
          url: url.toString(), callbackUrlScheme: "applink");

      final body = Uri.parse(result).queryParameters;
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: body['id_token'],
        accessToken: body['code'],
      );
      return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
    }
  }

  Future<UserCredential> signInWithKakao() async {
    final clientState = Uuid().v4();
    final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
      'response_type': 'code',
      'client_id': "13407065ab978c5016a8048dc6203708",
      'response_mode': 'form_post',
      'redirect_uri':
          'https://silken-whispering-porpoise.glitch.me/callbacks/kakao/sign_in_with_kakao',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: "webauthcallback");

    final body = Uri.parse(result).queryParameters;
    print(body);
    final tokenUrl = Uri.https('kauth.kakao.com', '/oauth/token', {
      'grant_type': 'authorization_code',
      'client_id': "13407065ab978c5016a8048dc6203708",
      'redirect_uri':
          'https://silken-whispering-porpoise.glitch.me/callbacks/kakao/sign_in_with_kakao',
      'code': body['code'],
    });

    var response = await http.post(Uri.parse(tokenUrl.toString()));
    Map<String, dynamic> accessTokenResult = json.decode(response.body);

    var responseCustomToken = await http.post(
        Uri.parse(
            'https://silken-whispering-porpoise.glitch.me/callbacks/kakao/token'),
        body: {'accessToken': accessTokenResult['access_token']});

    return await FirebaseAuth.instance.signInWithCustomToken(responseCustomToken.body);
  }

  Future<UserCredential> signInWithNaver() async {
    final clientState = Uuid().v4();
    final url = Uri.https('nid.naver.com', '/oauth2.0/authorize', {
      'response_type': 'code',
      'client_id': "ZVXS7NEgwbNjBcvIbJtG",
      'response_mode': 'form_post',
      'redirect_uri':
      'https://silken-whispering-porpoise.glitch.me/callbacks/naver/sign_in_with_naver',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: "webauthcallback");

    final body = Uri.parse(result).queryParameters;
    print(body);
    final tokenUrl = Uri.https('nid.naver.com', '/oauth2.0/token', {
      'grant_type': 'authorization_code',
      'client_id': "ZVXS7NEgwbNjBcvIbJtG",
      'client_secret': 'tIve3bOBd6',
      'state': clientState,
      'code': body['code'],
    });

    var response = await http.post(Uri.parse(tokenUrl.toString()));
    Map<String, dynamic> accessTokenResult = json.decode(response.body);

    var responseCustomToken = await http.post(
        Uri.parse(
            'https://silken-whispering-porpoise.glitch.me/callbacks/naver/token'),
        body: {'accessToken': accessTokenResult['access_token']});

    return await FirebaseAuth.instance.signInWithCustomToken(responseCustomToken.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Firebase SNS Login'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              color: Colors.grey.withOpacity(0.3),
              child: Text('Google Login'),
              onPressed: signInWithGoogle,
            ),
            FlatButton(
              color: Colors.grey.withOpacity(0.3),
              child: Text('Apple Login'),
              onPressed: signInWithApple,
            ),
            FlatButton(
              color: Colors.grey.withOpacity(0.3),
              child: Text('Kakao Login'),
              onPressed: signInWithKakao,
            ),
            FlatButton(
              color: Colors.grey.withOpacity(0.3),
              child: Text('Naver Login'),
              onPressed: signInWithNaver,
            ),
          ],
        ),
      ),
    );
  }
}
