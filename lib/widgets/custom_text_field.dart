import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? textEditingController;
  final String? hintText;
  const CustomTextField({Key? key, this.textEditingController, this.hintText})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: Theme.of(context).textTheme.titleSmall!.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.normal,
      ),
      controller: textEditingController,
      decoration: InputDecoration(
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Colors.grey[400],
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
