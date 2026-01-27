import 'package:flutter/material.dart';
import '../../domain/entities/rapid_fire_level_entity.dart';

class RapidFireGamePage extends StatelessWidget {
  final RapidFireLevelEntity level;
  final VoidCallback onLevelComplete;

  const RapidFireGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(level.title)),
      body: Center(child: Text("Rapid Fire Game - Level ${level.level}")),
    );
  }
}
