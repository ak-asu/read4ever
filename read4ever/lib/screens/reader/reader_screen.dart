import 'package:flutter/material.dart';

class ReaderScreen extends StatelessWidget {
  final String chapterId;
  const ReaderScreen({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reader')),
      body: Center(child: Text('Chapter $chapterId — coming soon')),
    );
  }
}
