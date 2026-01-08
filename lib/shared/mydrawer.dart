import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pawpal_v2/models/user.dart';
import 'package:pawpal_v2/shared/animated_route.dart';
import 'package:pawpal_v2/views/login_screen.dart';
import 'package:pawpal_v2/views/main_screen.dart';
import 'package:pawpal_v2/views/home_screen.dart';
import 'package:pawpal_v2/views/MyProfile_screen.dart';
import 'package:pawpal_v2/myconfig.dart';

class MyDrawer extends StatefulWidget {
  final User? user;
  const MyDrawer({super.key, this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  late double screenHeight;
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              radius: 15,
              child: ClipOval(
                child: Image.network(
                  '${MyConfig.baseUrl}/pawpal/assets/user_profile/${widget.user?.profile_image}',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      width: 90,
                      height: 90,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            accountName: Text(widget.user?.name ?? 'Guest'),
            accountEmail: Text(widget.user?.email ?? 'Guest'),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(HomeScreen(user: widget.user)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.pets),
            title: Text('Pet'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(MainScreen(user: widget.user)),
              );
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.settings),
          //   title: Text('Settings'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     Navigator.pushReplacement(
          //       context,
          //       AnimatedRoute.slideFromRight(SettingPage(user: widget.user)),
          //     );
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              if (widget.user?.user_id == '0') {
                //showdialog
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Row(
                      children: const [
                        Icon(Icons.lock_outline, color: Color(0xFF1F3C88)),
                        SizedBox(width: 8),
                        Text("Login Required"),
                      ],
                    ),
                    content: const Text(
                      "Please login to continue and access this feature.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F3C88),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            AnimatedRoute.slideFromRight(LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );

                return;
              }
              Navigator.pop(context);
              if (widget.user != null) {
                Navigator.pushReplacement(
                  context,
                  AnimatedRoute.slideFromRight(
                    MyprofileScreen(user: widget.user!),
                  ),
                );
              }
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.login),
          //   title: Text('Login'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => LoginPage()),
          //     );
          //   },
          // ),
          const Divider(color: Colors.grey),
          SizedBox(
            height: screenHeight / 3.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text("Version 0.1b", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
