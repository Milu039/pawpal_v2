import 'package:flutter/material.dart';
import 'package:pawpal_v2/models/user.dart';

class MydonationScreen extends StatefulWidget {
  final User? user;
  const MydonationScreen({super.key, required this.user});

  @override
  State<MydonationScreen> createState() => _MydonationScreenState();
}

class _MydonationScreenState extends State<MydonationScreen> {


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}