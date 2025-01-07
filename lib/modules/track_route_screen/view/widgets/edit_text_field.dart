import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:track_route_pro/config/theme/app_colors.dart';
import 'package:track_route_pro/config/theme/app_textstyle.dart';

import '../../../../utils/utils.dart';

class EditTextField extends StatelessWidget {
  const EditTextField({
    required this.controller,
    required this.hintText,
    this.suffixIcon,
    this.onSuffixTap,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
  });
  final TextEditingController controller;

  final String hintText;
  final String? suffixIcon;
  final GestureTapCallback? onSuffixTap;

  final bool readOnly;
  final GestureTapCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      width: context.width,
      child: TextField(
        readOnly: readOnly,
          onTap: onTap,
          style: AppTextStyles(context).display12W400,
        decoration: InputDecoration(
          suffixIcon: suffixIcon == null? null : SvgPicture.asset(suffixIcon!),
          contentPadding: EdgeInsets.all(8),
          fillColor: AppColors.backgroundColor,
          filled: true,
          hintText: hintText,
         hintStyle: AppTextStyles(context).display12W400.copyWith(color: AppColors.color_969696),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent, // Transparent border
            ),
            borderRadius: BorderRadius.circular(5), // Border radius of 5
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent, // Transparent border on focus
            ),
            borderRadius: BorderRadius.circular(5), // Border radius of 5
          ),
        ),
        controller: controller,

        inputFormatters: inputFormatters ?? [Utils.doubleFormatter()],

      ),
    );
  }
}
