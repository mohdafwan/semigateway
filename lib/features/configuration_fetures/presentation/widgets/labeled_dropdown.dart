import 'package:flutter/material.dart';
import 'package:semicalibration/core/ui/appcolor.dart';
import 'package:semicalibration/core/ui/defaultDropDown.dart';

class LabeledDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String hint;

  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColor.fontColor,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        DefaultDropDown<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColor.fontColor,
                        fontSize: 14,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          hint: hint,
        ),
      ],
    );
  }
}
