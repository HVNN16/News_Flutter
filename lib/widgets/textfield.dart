// import 'package:flutter/material.dart';
//
// class CustomTextField extends StatelessWidget {
//   const CustomTextField(
//       {super.key,
//       required this.hint,
//       required this.label,
//       this.controller,
//       this.isPassword = false});
//   final String hint;
//   final String label;
//   final bool isPassword;
//   final TextEditingController? controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       obscureText: isPassword,
//       controller: controller,
//       decoration: InputDecoration(
//           hintText: hint,
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//           label: Text(label),
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(6),
//               borderSide: const BorderSide(color: Colors.grey, width: 1))),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    required this.label,
    this.controller,
    this.isPassword = false,
    this.prefixIcon,
  });

  final String hint;
  final String label;
  final bool isPassword;
  final TextEditingController? controller;
  final Icon? prefixIcon;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.isPassword && _obscureText,
      controller: widget.controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        labelText: widget.label,
        labelStyle: TextStyle(color: Colors.redAccent),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.redAccent,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade900,
      ),
    );
  }
}
