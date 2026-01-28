import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../../game/domain/repositories/game_repository.dart';
import 'dart:convert';

class AdminLevelEditorPage extends StatefulWidget {
  const AdminLevelEditorPage({super.key});

  @override
  State<AdminLevelEditorPage> createState() => _AdminLevelEditorPageState();
}

class _AdminLevelEditorPageState extends State<AdminLevelEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _levelNumberController = TextEditingController(text: '1');

  String _selectedGameType = 'grammar';
  String _selectedDifficulty = 'Beginner';
  bool _isGenerating = false;
  bool _isSaving = false;
  List<dynamic> _generatedContent = [];

  final List<String> _gameTypes = [
    'grammar',
    'speaking',
    'scramble',
    'word_match',
    'rapid_fire',
    'reading',
    'dictation',
    'typing'
  ];

  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  Future<void> _generateContent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);
    _generatedContent = []; // Clear previous

    final repository = getIt<GameRepository>();
    final result = await repository.generateAiContent(
      _selectedGameType,
      _topicController.text,
      _selectedDifficulty,
    );

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${failure.message}')),
          );
        }
      },
      (content) {
        if (mounted) {
          setState(() => _generatedContent = content);
        }
      },
    );

    if (mounted) setState(() => _isGenerating = false);
  }

  Future<void> _saveLevel() async {
    if (_generatedContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No content to save! Generate first.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final repository = getIt<GameRepository>();
    final levelData = {
      'gameType': _selectedGameType,
      'levelNumber': int.tryParse(_levelNumberController.text) ?? 1,
      'title': _topicController.text, // Using topic as title for now
      'description': 'AI Generated Level - $_selectedDifficulty',
      'content': _generatedContent,
    };

    final result = await repository.createGameLevel(levelData);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: ${failure.message}')),
          );
        }
      },
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Level saved successfully!')),
          );
          Navigator.pop(context);
        }
      },
    );

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: Text("AI Level Generator", style: TextStyle(fontSize: 20.sp)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputs(),
              SizedBox(height: 20.h),
              const Divider(color: Colors.white24),
              SizedBox(height: 10.h),
              Expanded(
                child: _generatedContent.isEmpty
                    ? Center(
                        child: Text(
                          "Generated content will appear here.",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 14.sp),
                        ),
                      )
                    : _buildContentPreview(),
              ),
              SizedBox(height: 20.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputs() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedGameType,
                dropdownColor: AppTheme.cardBg,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Game Type'),
                items: _gameTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGameType = val!),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedDifficulty,
                dropdownColor: AppTheme.cardBg,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Difficulty'),
                items: _difficulties
                    .map((diff) => DropdownMenuItem(
                          value: diff,
                          child: Text(diff,
                              style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedDifficulty = val!),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _topicController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Topic (e.g., Travel, Food)'),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _levelNumberController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Level Number'),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildContentPreview() {
    return ListView.builder(
      itemCount: _generatedContent.length,
      itemBuilder: (context, index) {
        final item = _generatedContent[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            const JsonEncoder.withIndent('  ').convert(item),
            style: TextStyle(
                color: Colors.greenAccent,
                fontFamily: 'monospace',
                fontSize: 12.sp),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateContent,
            icon: _isGenerating
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? "Generating..." : "Generate with AI"),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16.h)),
          ),
        ),
        if (_generatedContent.isNotEmpty) ...[
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveLevel,
              icon: _isSaving
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: Text(_isSaving ? "Saving..." : "Save Level"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h)),
            ),
          ),
        ]
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.white10)),
    );
  }
}
