import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_v2/myconfig.dart';
import 'package:pawpal_v2/views/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pawpal_v2/views/register_screen.dart';
import 'package:pawpal_v2/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool visible = true;
  bool isChecked = false;

  late User user;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login Page')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
        child: Center(
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.all(24.0),
              child: Image.asset('assets/images/icon.png' ,scale: 2,)
              ),
              SizedBox(height: 80),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  icon: Icon(Icons.email),
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: passwordController,
                obscureText: visible,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {});
                      if (visible) {
                        visible = false;
                      } else {
                        visible = true;
                      }
                    },
                    icon: Icon(Icons.visibility),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Row(
                  children: [
                    Text('Remember Me'),
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        isChecked = value!;
                        setState(() {});
                        if (isChecked) {
                          if (emailController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            prefUpdate(isChecked);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Preferences Stored"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please fill your email and password",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            isChecked = false;
                            setState(() {});
                          }
                        } else {
                          prefUpdate(isChecked);
                          if (emailController.text.isEmpty &&
                              passwordController.text.isEmpty) {
                            return;
                            // do nothing
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Preferences Removed"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          emailController.clear();
                          passwordController.clear();
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              ElevatedButton(onPressed: loginuser, child: Text('Login')),
              SizedBox(height: 5),
              TextButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: Text('dont have an account, register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void prefUpdate(bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      prefs.setString('email', emailController.text);
      prefs.setString('password', passwordController.text);
      prefs.setBool('rememberMe', isChecked);
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.remove('rememberMe');
    }
  }

  void loadPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberMe = prefs.getBool('rememberMe');
      if (rememberMe != null && rememberMe) {
        String? email = prefs.getString('email');
        String? password = prefs.getString('password');
        emailController.text = email ?? '';
        passwordController.text = password ?? '';
        isChecked = true;
        setState(() {});
      }
    });
  }

  void loginuser() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in email and password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    http
        .post(
          Uri.parse('${MyConfig.baseUrl}/pawpal/api/login_user.php'),
          body: {'email': email, 'password': password},
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            print(jsonResponse);
            if (resarray['status'] == 'success') {
              print(resarray['data'][0]);
              user = User.fromJson(resarray['data'][0]);

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Login successful"),
                  backgroundColor: Colors.green,
                ),
              );
              // Navigate to home page or dashboard
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(user: user),),
              );
            } else {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resarray['message']),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // Handle successful login here
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Login failed: ${response.statusCode}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
  }
}
