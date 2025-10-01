import 'package:flutter/material.dart';

class RingingPage extends StatefulWidget {
  const RingingPage({super.key});

  @override
  State<RingingPage> createState() => _RingingPageState();
}

class _RingingPageState extends State<RingingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ringing')),
      body: Center(child: Text('RingingTest')),
    );
  }
}
