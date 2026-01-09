import 'package:flutter/material.dart';
import 'package:pawpal_v2/models/user.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pawpal_v2/myconfig.dart';
import 'package:pawpal_v2/models/pet.dart';

class PaymentScreen extends StatefulWidget {
  final User? user;
  final int money;
  final Pet? pet;
  final String category;

  const PaymentScreen({super.key, required this.user, required this.money, required this.pet, required this.category,});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  late WebViewController _webcontroller;
  late double screenHeight, screenWidth, resWidth;
  late String userName, userEmail, userPhone, userID, petId;

  @override
  void initState() {
    userEmail = widget.user!.email.toString();
    userPhone = widget.user!.phone.toString();
    userName = widget.user!.name.toString();
    petId = widget.pet!.petId.toString();
    userID = widget.user!.user_id.toString();
    super.initState();
    _webcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
        Uri.parse(
          '${MyConfig.baseUrl}/pawpal/api/payment.php?email=$userEmail&phone=$userPhone&userid=$userID&name=$userName&credits=${widget.money}&petid=$petId&category=${widget.category}',
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color(0xFF1F3C88),
      ),
      body: WebViewWidget(controller: _webcontroller),
    );
  }
}