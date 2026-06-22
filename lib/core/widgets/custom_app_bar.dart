import 'package:flutter/material.dart';
import 'package:apploan/core/core.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBack,
    this.actions,
  }) : super(key: key);

  @override
  // Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColor.hardOrange),
        Positioned.fill(
          child: Image.asset(
            'assets/images/appbarbackground.png',
            fit: BoxFit.cover,
          ),
        ),
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack ?? () => Navigator.pop(context),
          ),
          title: Text(title, style: AppTextStyle.largeWhiteBold),
          actions: actions,
        ),
      ],
    );
  }
}
