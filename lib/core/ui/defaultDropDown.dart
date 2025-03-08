import 'package:flutter/material.dart';

class DefaultDropDown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;
  final String? hint;

  const DefaultDropDown({
    super.key,
    this.value,
    this.items,
    this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150, // Adjusted width for input
      height: 25,
      // ignore: sort_child_properties_last
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: Text(hint ?? ''),
          isExpanded: true,
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 20,
            ),
          ),
          dropdownColor: Colors.blue,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
    );
  }
}
