import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
