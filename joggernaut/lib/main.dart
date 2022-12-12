import 'package:flutter/material.dart';
import 'steps.dart';

// Firebase import
void main() {
  runApp(
      const MaterialApp(home: StepsPage(), debugShowCheckedModeBanner: false));
  startForegroundService();
}
