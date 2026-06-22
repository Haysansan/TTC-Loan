import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apploan/core/core.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    this.labelText,
    this.obscureText = false,
    this.enableSuggestions = false,
    this.autocorrect = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.onFieldSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.readOnly = false,
    this.minLine = 1,
    this.maxLine = 1,
    this.maxLength,
    this.focusNode,
    this.hintText,
    this.initialValue,
    this.autofocus = false,
    this.onTap,
    this.controller,
    this.prefixText,
    this.inputFormatters,
    this.errorText,
    this.enable = true,
    this.hintStyle = AppTextStyle.normalLightGreyRegular,
    this.filled,
    this.style = const TextStyle(color: AppColor.primaryText, fontSize: 12),
  }) : super(key: key);

  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;
  final String? labelText;
  final String? hintText;
  final String? initialValue;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final Function()? onTap;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int minLine;
  final int maxLine;
  final bool autofocus;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final bool enable;
  final TextStyle hintStyle;
  final bool? filled;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textInputAction: textInputAction,
      key: key,
      initialValue: initialValue,
      controller: controller,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      readOnly: readOnly,
      minLines: minLine,
      maxLength: maxLength,
      autofocus: autofocus,
      focusNode: focusNode,
      maxLines: maxLine,
      style: style,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        contentPadding: 15.padHorizontal,
        hintText: hintText,
        filled: filled,
        fillColor: AppColor.white,
        prefixIconColor: AppColor.primaryText,
        suffixIconColor: AppColor.primaryText,
        helperText: ' ',
        errorStyle: AppTextStyle.smallRedRegular,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColor.lightGrey, width: 1),
          borderRadius: UIConstants.radius.radiusAll,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: UIConstants.radius.radiusAll,
          borderSide: const BorderSide(color: AppColor.lightGrey, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: UIConstants.radius.radiusAll,
          borderSide: const BorderSide(color: AppColor.lightGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: UIConstants.radius.radiusAll,
          borderSide: const BorderSide(color: AppColor.lightGrey, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: UIConstants.radius.radiusAll,
          borderSide: const BorderSide(color: AppColor.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: UIConstants.radius.radiusAll,
          borderSide: const BorderSide(color: AppColor.red, width: 1),
        ),
        errorText: errorText,
        hintStyle: hintStyle,
        prefixText: prefixText,
      ),
      onTap: onTap,
      onChanged: onChanged,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enable,
    );
  }
}
