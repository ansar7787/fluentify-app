import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/speaking_partner_bloc.dart';
import '../bloc/speaking_partner_event.dart';
import '../bloc/speaking_partner_state.dart';
import '../../domain/entities/speaking_scenario_entity.dart';
import '../../domain/entities/chat_turn_entity.dart';

class SpeakingPartnerChatPage extends StatefulWidget {
  final SpeakingScenarioEntity scenario;
  const SpeakingPartnerChatPage({super.key, required this.scenario});

  @override
  State<SpeakingPartnerChatPage> createState() =>
      _SpeakingPartnerChatPageState();
}

class _SpeakingPartnerChatPageState extends State<SpeakingPartnerChatPage> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _audioRecorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final directory = await getApplicationDocumentsDirectory();
      String filePath =
          '${directory.path}/partner_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: filePath);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() => _isRecording = false);
    if (path != null) {
      context.read<SpeakingPartnerBloc>().add(SendUserSpeech(path));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.scenario.title,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            Text('Talking with ${widget.scenario.aiRole}',
                style:
                    TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
          ],
        ),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<SpeakingPartnerBloc, SpeakingPartnerState>(
              listener: (context, state) {
                if (state is ConversationActive) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ConversationActive) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    itemCount:
                        state.messages.length + (state.isAITyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return _buildTypingIndicator(isDark);
                      }
                      final msg = state.messages[index];
                      return _buildMessageBubble(msg, isDark);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildBottomPanel(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageEntity msg, bool isDark) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        decoration: BoxDecoration(
          gradient: msg.isUser ? AppColors.primaryGradient : null,
          color: msg.isUser
              ? null
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
            bottomLeft: msg.isUser ? Radius.circular(20.r) : Radius.zero,
            bottomRight: msg.isUser ? Radius.zero : Radius.circular(20.r),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Text(
          msg.content,
          style: TextStyle(
            color: msg.isUser
                ? Colors.white
                : (isDark ? Colors.white : AppColors.textHeadline),
            fontSize: 15.sp,
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Analyzing speech...',
                style:
                    TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
            SizedBox(width: 8.w),
            SizedBox(
              width: 12.w,
              height: 12.w,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildBottomPanel(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).padding.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isRecording
              ? Text('Listening...',
                  style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp))
              : Text('Hold to speak',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 14.sp)),
          SizedBox(height: 16.h),
          GestureDetector(
            onLongPress: _startRecording,
            onLongPressUp: _stopRecording,
            child: Container(
              height: 80.w,
              width: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isRecording
                    ? LinearGradient(colors: [Colors.red, Colors.red[700]!])
                    : AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.red : AppColors.primary)
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Icon(
                _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: Colors.white,
                size: 36.w,
              ),
            )
                .animate(onPlay: (c) => _isRecording ? c.repeat() : c.stop())
                .shake(hz: 3),
          ),
        ],
      ),
    );
  }
}
