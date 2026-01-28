import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/reading_level_entity.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../games/reading_game_page.dart';

class ReadingLevelsPage extends StatefulWidget {
  const ReadingLevelsPage({super.key});

  @override
  State<ReadingLevelsPage> createState() => _ReadingLevelsPageState();
}

class _ReadingLevelsPageState extends State<ReadingLevelsPage> {
  int _highestUnlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highestUnlockedLevel = prefs.getInt('reading_highest_level') ?? 1;
    });
  }

  Future<void> _updateProgress(int completedLevel) async {
    if (completedLevel >= _highestUnlockedLevel) {
      final newLevel = completedLevel + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reading_highest_level', newLevel);
      setState(() {
        _highestUnlockedLevel = newLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF59E0B); // Amber

    return BlocProvider(
      create: (context) => getIt<GameBloc>()..add(GetReadingLevelsEvent()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: const Text('Reading Quest',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            if (state is GameLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: primaryColor));
            } else if (state is ReadingLevelsLoaded) {
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.levels.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final level = state.levels[index];
                  final isUnlocked = level.level <= _highestUnlockedLevel;
                  return ListTile(
                    enabled: isUnlocked,
                    leading: Icon(Icons.book,
                        color: isUnlocked ? primaryColor : Colors.grey),
                    title: Text(level.title),
                    subtitle: Text(isUnlocked ? 'Tap to read' : 'Locked'),
                    trailing: isUnlocked
                        ? const Icon(Icons.chevron_right)
                        : const Icon(Icons.lock, size: 16),
                    onTap: isUnlocked
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ReadingGamePage(
                                        level: level,
                                        onLevelComplete: () =>
                                            _updateProgress(level.level))));
                          }
                        : null,
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
