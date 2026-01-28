import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../domain/entities/typing_level_entity.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../games/typing_game_page.dart';

class TypingLevelsPage extends StatefulWidget {
  const TypingLevelsPage({super.key});

  @override
  State<TypingLevelsPage> createState() => _TypingLevelsPageState();
}

class _TypingLevelsPageState extends State<TypingLevelsPage> {
  int _highestUnlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highestUnlockedLevel = prefs.getInt('typing_highest_level') ?? 1;
    });
  }

  Future<void> _updateProgress(int completedLevel) async {
    if (completedLevel >= _highestUnlockedLevel) {
      final newLevel = completedLevel + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('typing_highest_level', newLevel);
      setState(() {
        _highestUnlockedLevel = newLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFFEC4899); // Pink

    return BlocProvider(
      create: (context) => getIt<GameBloc>()..add(GetTypingLevelsEvent()),
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            _buildBackground(isDark, primaryColor),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(context, isDark, primaryColor),
                  _buildProgressHeader(isDark, primaryColor),
                  Expanded(
                    child: BlocBuilder<GameBloc, GameState>(
                      builder: (context, state) {
                        if (state is GameLoading) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor));
                        } else if (state is TypingLevelsLoaded) {
                          return _buildLevelsList(
                              state.levels, isDark, primaryColor);
                        } else if (state is GameError) {
                          return Center(child: Text(state.message));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelsList(
      List<TypingLevelEntity> levels, bool isDark, Color color) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      physics: const BouncingScrollPhysics(),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final isUnlocked = level.level <= _highestUnlockedLevel;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ListTile(
            onTap: isUnlocked
                ? () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => TypingGamePage(
                                level: level,
                                onLevelComplete: () =>
                                    _updateProgress(level.level))));
                  }
                : null,
            tileColor: isUnlocked ? Colors.white : Colors.grey[200],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: CircleAvatar(
              backgroundColor: isUnlocked ? color : Colors.grey,
              child: Text('${level.level}',
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(level.title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.black : Colors.grey)),
            trailing: isUnlocked
                ? const Icon(Icons.arrow_forward_ios, size: 16)
                : const Icon(Icons.lock, size: 16),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, Color color) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: BackButton(color: isDark ? Colors.white : Colors.black),
      title: Text('Speed Typer',
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildProgressHeader(bool isDark, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      child: LinearProgressIndicator(
          value: _highestUnlockedLevel / 100,
          color: color,
          backgroundColor: color.withOpacity(0.2)),
    );
  }

  Widget _buildBackground(bool isDark, Color color) {
    return Container(); // Simple background
  }
}
