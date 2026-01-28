import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/entities/rapid_fire_level_entity.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../games/rapid_fire_game_page.dart';

class RapidFireLevelsPage extends StatefulWidget {
  const RapidFireLevelsPage({super.key});

  @override
  State<RapidFireLevelsPage> createState() => _RapidFireLevelsPageState();
}

class _RapidFireLevelsPageState extends State<RapidFireLevelsPage> {
  int _highestUnlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highestUnlockedLevel = prefs.getInt('rapid_fire_highest_level') ?? 1;
    });
  }

  Future<void> _updateProgress(int completedLevel) async {
    if (completedLevel >= _highestUnlockedLevel) {
      final newLevel = completedLevel + 1;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('rapid_fire_highest_level', newLevel);
      setState(() {
        _highestUnlockedLevel = newLevel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFEF4444); // Red

    return BlocProvider(
      create: (context) => getIt<GameBloc>()..add(GetRapidFireLevelsEvent()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFF7F1D1D)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text('RAPID FIRE',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
              const Text('Think Fast. Act Faster.',
                  style: TextStyle(color: Colors.white70)),
              Expanded(
                child: BlocBuilder<GameBloc, GameState>(
                  builder: (context, state) {
                    if (state is GameLoading) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    } else if (state is RapidFireLevelsLoaded) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
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
                                            builder: (_) => RapidFireGamePage(
                                                level: level,
                                                onLevelComplete: () =>
                                                    _updateProgress(
                                                        level.level))));
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    isUnlocked ? Colors.white : Colors.white10,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: isUnlocked
                                    ? [
                                        BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5))
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: isUnlocked
                                    ? Text('${level.level}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: primaryColor))
                                    : const Icon(Icons.lock,
                                        color: Colors.white38),
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
            ],
          ),
        ),
      ),
    );
  }
}
