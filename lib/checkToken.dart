import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:member_login/home.dart';
import 'package:member_login/login.dart';

class CheckToken extends StatefulWidget {
  @override
  _CheckTokenState createState() => _CheckTokenState();
}

class _CheckTokenState extends State<CheckToken> {
  @override
  void initState() {
    super.initState();
    checkInternetConnection_2();
  }

  Future<void> checkTokenAndNavigate() async {
    final storage = FlutterSecureStorage();
    String? storedToken = await storage.read(key: 'token');

    if (storedToken != null) {
      bool isValidToken = await validateToken(storedToken);

      if (isValidToken) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
        return;
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<bool> validateToken(String token) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/validate_token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 4));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['valid'] == true) {
        return true;
      }
    }
    return false;
  }

  void checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:5000/'))
          .timeout(Duration(seconds: 3));

      if (response.statusCode == 200) {
        checkTokenAndNavigate();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Sunucuyla Bağlantı Kurulamadı..",
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.white,
          ),
        );

        exitApp(2);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Sunucuyla Bağlantı Kurulamadı..",
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
        ),
      );
      exitApp(2);
    }
  }

  void checkInternetConnection_2() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Lütfen Bağlantınızı Kontrol Edin..",
            style: GoogleFonts.quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
        ),
      );

      exitApp(2);
    } else
      checkConnection();
  }

  void exitApp(int a) {
    Future.delayed(Duration(seconds: a), () {
      SystemNavigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child:
              Center(child: Icon(Icons.downloading, color: Color(0xFF29235C)))),
    );
  }
}
