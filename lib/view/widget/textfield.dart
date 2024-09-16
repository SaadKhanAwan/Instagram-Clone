import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final String? Function(String?)? onsave;
  final String? hintText;
  final String? initaialValue;
  final IconData? prefixicon;
  final IconData? sufixicon1;
  final IconData? sufixicon2;
  final bool isobscure;
  final VoidCallback? iconFunction;
  const MyTextField({
    super.key,
    this.onsave,
    this.controller,
    this.initaialValue,
    this.iconFunction,
    this.sufixicon1,
    this.sufixicon2,
    this.isobscure = false,
    this.onChanged,
    this.validator,
    this.hintText = 'Type something...',
    this.prefixicon = Icons.email,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initaialValue,
      onSaved: onsave,
      obscureText: isobscure,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(prefixicon),
        suffixIcon: InkWell(
            onTap: iconFunction,
            child: Icon(isobscure ? sufixicon1 : sufixicon2)),
        filled: true,
        fillColor: secondaryColor,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.black)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.red)),
      ),
      validator: validator,
    );
  }
}
