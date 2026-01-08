import 'package:flutter/material.dart';
import 'package:pawpal_v2/views/login_screen.dart';
import 'package:pawpal_v2/models/user.dart';
import 'package:pawpal_v2/views/main_screen.dart';
import 'package:pawpal_v2/views/submit_pet_screen.dart';
import 'package:pawpal_v2/shared/mydrawer.dart';
class HomeScreen extends StatefulWidget {
  final User? user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: Icon(Icons.door_back_door),
          ),
        ],
      ),
      body: Center(child: Column(
        children: [
          SizedBox(height: 20,),
          Text('Welcome, ${widget.user?.name}'),
          SizedBox(height: 20,),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(user: widget.user)),);
          }, child: Text('View Pets')),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SubmitPetScreen(user: widget.user),),
          );
        },
        child: Icon(Icons.add),
      ),
      drawer: MyDrawer(user: widget.user),
    );
  }
}
