import 'package:flutter/material.dart';
import 'package:flutter_spotify_clone/core/theme/app_pallete.dart';

class AuthGradientButton extends StatelessWidget {
  final String btnName;

  final VoidCallback onTap;

  const AuthGradientButton({
    super.key,
    required this.btnName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Palette.gradient1, Palette.gradient2],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(395, 55),
          backgroundColor: Palette.transparentColor,
          shadowColor: Palette.transparentColor,
        ),
        onPressed: onTap,
        child: Text(
          btnName,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
