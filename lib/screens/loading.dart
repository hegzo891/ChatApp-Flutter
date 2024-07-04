import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class loadingpage extends StatefulWidget {
  const loadingpage({super.key});

  @override
  State<loadingpage> createState() => _loadingpageState();
}

class _loadingpageState extends State<loadingpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: SpinKitChasingDots(
            color: Colors.black,
            size: 50,
          ),
        ),
      ),
    );
  }
}
