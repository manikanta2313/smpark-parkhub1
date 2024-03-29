import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ForwardButton extends StatelessWidget {
  const ForwardButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Ionicons.chevron_forward_outline),
      ),
    );
  }
}