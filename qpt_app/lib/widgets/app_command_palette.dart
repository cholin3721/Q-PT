// lib/widgets/app_command_palette.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppCommandPalette extends StatefulWidget {
  const AppCommandPalette({super.key});

  @override
  State<AppCommandPalette> createState() => _AppCommandPaletteState();
}

class _AppCommandPaletteState extends State<AppCommandPalette> {
  // 1. 검색창을 제어하기 위한 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  // 2. 검색 가능한 모든 명령어 목록 (예시 데이터)
  final List<String> _allCommands = [
    'Profile', 'Billing', 'Settings', 'Keyboard shortcuts',
    'New Team', 'Invite members', 'Log out', 'API Keys'
  ];

  // 3. 필터링된 명령어 목록을 저장할 리스트 (처음엔 모든 목록을 보여줌)
  late List<String> _filteredCommands;

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때, 필터링된 목록을 전체 목록으로 초기화
    _filteredCommands = _allCommands;
    // 검색창에 글자가 입력될 때마다 _filterCommands 함수를 실행하도록 리스너 추가
    _searchController.addListener(_filterCommands);
  }

  // 4. 위젯이 화면에서 사라질 때 컨트롤러를 정리 (메모리 누수 방지)
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 5. 검색어에 따라 명령어 목록을 필터링하는 함수
  void _filterCommands() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommands = _allCommands.where((command) {
        return command.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 다이얼로그의 내용물을 구성
    return Column(
      mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 Column 높이를 차지
      children: [
        // 검색창 (TextField)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            autofocus: true, // 다이얼로그가 뜨면 바로 키보드 포커스를 줌
            decoration: InputDecoration(
              hintText: 'Search for a command...',
              prefixIcon: const Icon(Icons.search, color: AppColors.mutedForeground),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.outlineBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const Divider(height: 1),

        // 필터링된 명령어 목록 (ListView)
        SizedBox(
          // 목록의 최대 높이를 300으로 제한
          height: 300,
          child: ListView.builder(
            itemCount: _filteredCommands.length,
            itemBuilder: (context, index) {
              final command = _filteredCommands[index];
              return ListTile(
                title: Text(command),
                onTap: () {
                  // 명령어를 선택했을 때의 동작
                  print('Selected command: $command');
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
              );
            },
          ),
        ),
      ],
    );
  }
}