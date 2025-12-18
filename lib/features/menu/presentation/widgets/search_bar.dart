import 'package:flutter/material.dart';

class MenuSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;

  const MenuSearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
  });

  @override
  State<MenuSearchBar> createState() => _MenuSearchBarState();
}

class _MenuSearchBarState extends State<MenuSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? Colors.green : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: "Search menu...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.filter_list,
                color: isFocused ? Colors.green : Colors.grey),
            onPressed: widget.onFilterTap,
          ),
        ],
      ),
    );
  }
}