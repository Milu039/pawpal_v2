import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_v2/myconfig.dart';
import 'package:pawpal_v2/views/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool visible = false;
  bool isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 40),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  icon: Icon(Icons.email),
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  icon: Icon(Icons.phone),
                  labelText: 'Phone',
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
              TextFormField(
                controller: confirmPasswordController,
                obscureText: visible,
                decoration: InputDecoration(
                  icon: Icon(Icons.lock),
                  labelText: 'Confirm Password',
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
              SizedBox(height:20),
              ElevatedButton(onPressed: registerDialog, child: Text('Register')),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text('Already have account, Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void registerDialog() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please fill in all fields'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please enter a valid email address'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (!(password == confirmPassword)) {
      SnackBar snackBar = const SnackBar(
        content: Text('Make sure your password and confirm password are same'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (password.length < 6) {
      SnackBar snackBar = const SnackBar(
        content: Text('Password must be at least 6 characters long'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Register this account?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              registerUser(email, password, name, phone);
            },
            child: Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void registerUser(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    setState(() {
      isLoading = true;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Registering ...'),
            ],
          ),
        );
      },
      barrierDismissible: false,
    );
    await http
        .post(
          Uri.parse('${MyConfig.baseUrl}/pawpal/api/register_user.php'),
          body: {
            'email': email,
            'name': name,
            'phone': phone,
            'password': password,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            print(jsonResponse);
            if (resarray['status'] == 'success') {
              if (!mounted) return;
              SnackBar snackBar = const SnackBar(
                content: Text('Registration successful'),
              );
              if (isLoading) {
                if (!mounted) return;
                Navigator.pop(context);
                setState(() {
                  isLoading = false;
                });
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            } else {
              if (!mounted) return;
              SnackBar snackBar = SnackBar(content: Text(resarray['message']));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          } else {
            if (!mounted) return;
            SnackBar snackBar = const SnackBar(
              content: Text('Registration failed. Please try again.'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        })
        .timeout(
          Duration(seconds: 10),
          onTimeout: () {
            if (!mounted) return;
            SnackBar snackBar = const SnackBar(
              content: Text('Request timed out. Please try again.'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        );

    if (isLoading) {
      if (!mounted) return;
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
    }
  }
}
