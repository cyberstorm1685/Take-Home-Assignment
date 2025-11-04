import 'package:flutter/material.dart';

class PostItem extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onTap;
  const PostItem({super.key, required this.title, required this.body, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}
