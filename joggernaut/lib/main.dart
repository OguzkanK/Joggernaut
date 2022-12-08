import 'package:flutter/material.dart';
import 'steps.dart';

void main() {
  runApp(
      const MaterialApp(home: StepsPage(), debugShowCheckedModeBanner: false));
  startForegroundService();
}
