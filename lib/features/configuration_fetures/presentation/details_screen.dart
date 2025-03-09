import 'package:flutter/material.dart';
import 'package:semicalibration/core/ui/appcolor.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        actions: const [
          Text('Help', style: TextStyle(color: Colors.white, fontSize: 20)),
          SizedBox(width: 10),
        ],
      ),
      body: const Center(
        child: Text('Details Content Here'),
      ),
    );
  }
}
