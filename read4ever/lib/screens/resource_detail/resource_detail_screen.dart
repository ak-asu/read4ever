import 'package:flutter/material.dart';

class ResourceDetailScreen extends StatelessWidget {
  final String id;
  const ResourceDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resource Detail')),
      body: Center(child: Text('Resource $id — coming soon')),
    );
  }
}
