import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  bool isChecked = false;
  bool showPasswordIcon = true;
  late Box box1;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<String?> login(String username, String password) async {
    try {
      Uri uri = Uri.http("10.0.2.2:5000", "/user_login",
          {"Tc": emailController.text, "Sifre": passwordController.text});

      http.Response response =
          await http.get(uri).timeout(Duration(seconds: 4));

      if (response.statusCode == 200) {
        final token = response.body;
        saveToken(token);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
        return token;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Lütfen Giriş Bilgilerinizi Kontrol Edin.",
              style: GoogleFonts.quicksand(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.white,
          ),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Sunucuyla Bağlantı Kurulamadı..",
            style: GoogleFonts.quicksand(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
        ),
      );
      return null;
    }
  }

  void checkInternetConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Lütfen Bağlantınızı Kontrol Edin..",
            style: GoogleFonts.quicksand(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
        ),
      );
    } else if (emailController.text == "" || passwordController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Giriş Alanları Boş Bırakılamaz..",
            style: GoogleFonts.quicksand(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
        ),
      );
    } else {
      String username = emailController.text;
      String password = passwordController.text;
      login(username, password);
    }
  }

  void saveToken(String token) async {
    final storage = FlutterSecureStorage();
    await storage.write(key: 'token', value: token);
  }

  void simulateLogin() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    createBox();
  }

  void createBox() async {
    box1 = await Hive.openBox('logindata');
    getdata();
  }

  void getdata() async {
    if (box1.get('email') != null) {
      emailController.text = box1.get('email');
      isChecked = true;
      setState(() {});
    }
  }

  void remember() {
    if (isChecked) {
      box1.put('email', emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  height: 360,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          "Hesabınıza Giriş Yapın",
                          style: GoogleFonts.quicksand(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(right: 17, left: 17, top: 30),
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(),
                                hintText: ("E-Posta Adresinizi Girin"),
                                prefixIcon: Icon(Icons.mail_outline_rounded,
                                    color: Color(0xFF29235C))),
                            style: GoogleFonts.quicksand(
                              color: Colors.black,
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            right: 17, left: 17, top: 15, bottom: 10),
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                  controller: passwordController,
                                  obscureText: showPasswordIcon,
                                  decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(),
                                      hintText: ("Şifrenizi Girin"),
                                      prefixIcon: Icon(Icons.vpn_key_outlined,
                                          color: Color(0xFF29235C))),
                                  style: GoogleFonts.quicksand(
                                    color: Color(0xFF29235C),
                                  )),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  showPasswordIcon = !showPasswordIcon;
                                });
                              },
                              icon: Icon(
                                showPasswordIcon
                                    ? Icons.remove_red_eye_outlined
                                    : Icons.close,
                                color: Color(0xFF29235C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Beni Hatırla",
                              style: GoogleFonts.quicksand(
                                  color: Color(0xFF29235C), fontSize: 19)),
                          Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              isChecked = !isChecked;
                              setState(() {});
                            },
                            activeColor: Colors.black,
                            checkColor: Colors.white,
                          ),
                        ],
                      ),
                      Container(
                        height: 45.0,
                        width: 250.0,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 4),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  simulateLogin();
                                  checkInternetConnection();
                                  remember();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: isLoading
                                ? Text(
                                    "Giriş Yapılıyor",
                                    key: ValueKey('loading'),
                                    style: GoogleFonts.quicksand(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Giriş Yap",
                                    key: ValueKey('normal'),
                                    style: GoogleFonts.quicksand(
                                        fontSize: 18, color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
