import 'package:examen_harold_app/components/loader_component.dart';
import 'package:flutter/material.dart';

class WaitScreen extends StatelessWidget {
  const WaitScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoaderComponent(text: 'Por favor espere...',),
    );
  }
}