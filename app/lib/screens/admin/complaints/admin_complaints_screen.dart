import 'package:flutter/material.dart';

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Complaint")));
  }
}
