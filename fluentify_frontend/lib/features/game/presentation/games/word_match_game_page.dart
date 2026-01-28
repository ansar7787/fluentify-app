import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../../domain/entities/word_match_level_entity.dart';
import '../../domain/entities/word_match_challenge_entity.dart';

class WordMatchGamePage extends StatefulWidget {
  final WordMatchLevelEntity level;
  final VoidCallback onLevelComplete;

  const WordMatchGamePage(
      {super.key, required this.level, required this.onLevelComplete});

  @override
  State<WordMatchGamePage> createState() => _WordMatchGamePageState();
}

class _WordMatchGamePageState extends State<WordMatchGamePage> {
  late List<WordMatchChallengeEntity> _challenges;
  int _currentChallengeIndex = 0;

  // Game State
  late List<String> _leftItems;
  late List<String> _rightItems;
  String? _selectedLeft;
  String? _selectedRight;
  final Set<String> _matchedPairs = {}; // Stores the 'word' from the pair
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _challenges = widget.level.challenges;
    _setupChallenge();
  }

  void _setupChallenge() {
    if (_currentChallengeIndex >= _challenges.length) return;

    final challenge = _challenges[_currentChallengeIndex];

    // Prepare items for columns
    _leftItems = challenge.pairs.map((e) => e.word).toList()..shuffle();
    _rightItems = challenge.pairs.map((e) => e.match).toList()..shuffle();

    _matchedPairs.clear();
    _selectedLeft = null;
    _selectedRight = null;
    _isProcessing = false;
    setState(() {});
  }

  void _handleSelection(String item, bool isLeft) {
    if (_isProcessing) return;
    // Don't select if already matched
    if (_isItemMatched(item, isLeft)) return;

    setState(() {
      if (isLeft) {
        if (_selectedLeft == item)
          _selectedLeft = null; // Deselect
        else
          _selectedLeft = item;
      } else {
        if (_selectedRight == item)
          _selectedRight = null; // Deselect
        else
          _selectedRight = item;
      }
    });

    _checkMatch();
  }

  void _checkMatch() async {
    if (_selectedLeft != null && _selectedRight != null) {
      _isProcessing = true;
      final challenge = _challenges[_currentChallengeIndex];

      // Find the pair for the selected left item
      final pair = challenge.pairs.firstWhere((e) => e.word == _selectedLeft);

      final isMatch = pair.match == _selectedRight;

      if (isMatch) {
        // Success
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          _matchedPairs.add(_selectedLeft!);
          _selectedLeft = null;
          _selectedRight = null;
          _isProcessing = false;
        });
        _checkCompletion();
      } else {
        // Failure
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _selectedLeft = null;
          _selectedRight = null;
          _isProcessing = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Incorrect match! Try again.'),
              backgroundColor: Colors.red.withOpacity(0.8),
              duration: const Duration(milliseconds: 500),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  bool _isItemMatched(String item, bool isLeft) {
    if (isLeft) {
      return _matchedPairs.contains(item);
    } else {
      // For right side, we need to check if the MATCH is in the pair of a matched word
      final challenge = _challenges[_currentChallengeIndex];
      for (final matchedWord in _matchedPairs) {
        final pair = challenge.pairs.firstWhere((p) => p.word == matchedWord);
        if (pair.match == item) return true;
      }
      return false;
    }
  }

  void _checkCompletion() {
    if (_matchedPairs.length ==
        _challenges[_currentChallengeIndex].pairs.length) {
      // Challenge Complete
      if (_currentChallengeIndex < _challenges.length - 1) {
        // Next Challenge
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _currentChallengeIndex++;
              _setupChallenge();
            });
          }
        });
      } else {
        // Level Complete
        if (mounted) {
          final currentUser = context.read<UserBloc>().state;
          int currentLevel = 1;
          if (currentUser is UserLoaded) {
            currentLevel = currentUser.user.wordMatchLevel;
          }

          // Only update if we completed a higher level
          if (widget.level.level >= currentLevel) {
            context.read<UserBloc>().add(
                  UpdateUserProfileEvent(
                      wordMatchLevel: widget.level.level + 1),
                );
          }
        }

        widget.onLevelComplete();
        _showLevelCompleteDialog();
      }
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration_rounded,
                      color: Colors.amber, size: 64)
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              const Text("Level Complete!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("You've mastered Level ${widget.level.level}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to levels
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Continue"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentChallengeIndex >= _challenges.length)
      return const SizedBox.shrink();
    final challenge = _challenges[_currentChallengeIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.level.title,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Center(
              child: Text(
                "${_currentChallengeIndex + 1}/${_challenges.length}",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    color: const Color(0xFF8B5CF6)),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
                border:
                    Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
              ),
              child: Text(
                challenge.instruction,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildColumn(_leftItems, true)),
                  SizedBox(width: 24.w),
                  Expanded(child: _buildColumn(_rightItems, false)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(List<String> items, bool isLeft) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected =
            isLeft ? _selectedLeft == item : _selectedRight == item;
        final isMatched = _isItemMatched(item, isLeft);

        return GestureDetector(
          onTap: () => _handleSelection(item, isLeft),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: isMatched
                  ? Colors.green.shade100.withOpacity(0.5)
                  : (isSelected ? const Color(0xFF8B5CF6) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isMatched
                    ? Colors.green.withOpacity(0.5)
                    : (isSelected
                        ? const Color(0xFF8B5CF6)
                        : Colors.grey.shade200),
                width: 2,
              ),
              boxShadow: isMatched || isSelected
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isLeft && isMatched)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                Expanded(
                  child: Text(
                    item,
                    textAlign: isLeft ? TextAlign.left : TextAlign.right,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isMatched
                          ? Colors.green.shade700
                          : (isSelected
                              ? Colors.white
                              : const Color(0xFF1E293B)),
                      decoration: isMatched ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.green.shade700,
                    ),
                  ),
                ),
                if (isLeft && isMatched)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
