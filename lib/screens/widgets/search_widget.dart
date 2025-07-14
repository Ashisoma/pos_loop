import 'package:flutter/material.dart';

class ReusableSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const ReusableSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: TextField(
        onChanged: onChanged,

        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
