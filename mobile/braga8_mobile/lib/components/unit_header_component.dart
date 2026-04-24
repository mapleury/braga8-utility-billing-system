import 'package:flutter/material.dart';

class UnitHeaderComponent extends StatelessWidget {
  final Function(String) onSearch;
  final VoidCallback onFilterTap;

  const UnitHeaderComponent({
    super.key,
    required this.onSearch,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daftar Unit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: Colors.blue),
              onPressed: onFilterTap,
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: onSearch,
          decoration: InputDecoration(
            hintText: 'Search Unit or Tenant...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
