import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/dictation_level_entity.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../games/dictation_game_page.dart';

class DictationLevelsPage extends StatefulWidget {
  const DictationLevelsPage({super.key});

  @override
  State<DictationLevelsPage> createState() => _DictationLevelsPageState();
}

class _DictationLevelsPageState extends State<DictationLevelsPage> {
  int _highestUnlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highestUnlockedLevel = prefs.getInt('dictation_highest_level') ?? 1;
    });
  }

  Future<void> _updateProgress(int completedLevel) async {
    if (completedLevel >= _highestUnlockedLevel) {
      final newLevel = completedLevel + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('dictation_highest_level', newLevel);
      setState(() {
        _highestUnlockedLevel = newLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF10B981); // Emerald

    return BlocProvider(
      create: (context) => getIt<GameBloc>()..add(GetDictationLevelsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFF10B981),
        body: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('Diction Master',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                leading: const BackButton(color: Colors.white),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                  ),
                  child: BlocBuilder<GameBloc, GameState>(
                    builder: (context, state) {
                      if (state is GameLoading) {
                        return const Center(
                            child:
                                CircularProgressIndicator(color: primaryColor));
                      } else if (state is DictationLevelsLoaded) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: state.levels.length,
                          itemBuilder: (context, index) {
                            final level = state.levels[index];
                            final isUnlocked =
                                level.level <= _highestUnlockedLevel;
                            return GestureDetector(
                              onTap: isUnlocked
                                  ? () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => DictationGamePage(
                                                  level: level,
                                                  onLevelComplete: () =>
                                                      _updateProgress(
                                                          level.level))));
                                    }
                                  : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? primaryColor.withOpacity(0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: isUnlocked
                                          ? primaryColor
                                          : Colors.transparent),
                                ),
                                child: Center(
                                  child: Text('${level.level}',
                                      style: TextStyle(
                                          color: isUnlocked
                                              ? primaryColor
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
