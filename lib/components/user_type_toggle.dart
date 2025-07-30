import 'package:flutter/material.dart';

typedef UserTypeChanged = void Function(String type);

class UserTypeToggle extends StatelessWidget {
  final String selectedType;
  final UserTypeChanged onChanged;

  const UserTypeToggle({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => onChanged('admin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedType == 'admin' ? Colors.deepPurple : Colors.grey[200],
              foregroundColor: selectedType == 'admin' ? Colors.white : Colors.deepPurple,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              elevation: 0,
            ),
            child: const Text('Admin'),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () => onChanged('manager'),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedType == 'manager' ? Colors.deepPurple : Colors.grey[200],
              foregroundColor: selectedType == 'manager' ? Colors.white : Colors.deepPurple,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              elevation: 0,
            ),
            child: const Text('Manager'),
          ),
        ),
      ],
    );
  }
} 
