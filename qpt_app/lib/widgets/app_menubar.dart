// lib/widgets/app_menubar.dart

import 'package:flutter/material.dart';
import 'app_dropdown_menu.dart';

class AppMenubar extends StatelessWidget {
  const AppMenubar({super.key});

  @override
  Widget build(BuildContext context) {
    // Menubar는 AppDropdownMenu의 수평 목록입니다.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "File" 메뉴
          AppDropdownMenu(
            trigger: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('File'),
            ),
            menuItems: const [
              PopupMenuItem(value: 'new', child: Text('New Tab')),
              PopupMenuItem(value: 'open', child: Text('Open File...')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'exit', child: Text('Exit')),
            ],
            onSelected: (value) => print('File > $value selected'),
          ),
          // "Edit" 메뉴
          AppDropdownMenu(
            trigger: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Edit'),
            ),
            menuItems: const [
              PopupMenuItem(value: 'undo', child: Text('Undo')),
              PopupMenuItem(value: 'redo', child: Text('Redo')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'cut', child: Text('Cut')),
              PopupMenuItem(value: 'copy', child: Text('Copy')),
              PopupMenuItem(value: 'paste', child: Text('Paste')),
            ],
            onSelected: (value) => print('Edit > $value selected'),
          ),
        ],
      ),
    );
  }
}