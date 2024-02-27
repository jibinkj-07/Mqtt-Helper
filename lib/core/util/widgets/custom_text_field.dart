import 'package:flutter/material.dart';

/// @author : Jibin K John
/// @date   : 22/02/2024
/// @time   : 10:36:31

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String?)? onSaved;
  final String? initialValue;
  final bool? obscureText;
  final Widget? suffix;
  final int? maxLines;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.validator,
    this.onSaved,
    this.textInputAction,
    required this.textCapitalization,
    this.keyboardType,
    this.initialValue,
    this.obscureText,
    this.suffix,
    this.maxLines,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      initialValue: initialValue,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      maxLines: maxLines,
      minLines: 1,
      decoration: InputDecoration(
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        labelText: labelText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.0,
            color: Colors.black,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.0,
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            width: 1.5,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
