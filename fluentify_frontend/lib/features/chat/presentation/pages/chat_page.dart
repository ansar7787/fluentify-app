import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/chat_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChatPage extends StatelessWidget {
  final String room;
  final String currentUser;

  const ChatPage({super.key, required this.room, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ChatBloc>()..add(ChatConnect(room)),
      child: ChatView(currentUser: currentUser, room: room),
    );
  }
}

class ChatView extends StatefulWidget {
  final String currentUser;
  final String room;

  const ChatView({super.key, required this.currentUser, required this.room});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    context.read<ChatBloc>().add(ChatSendMessage(
          room: widget.room,
          message: _controller.text.trim(),
          sender: widget.currentUser,
          senderId: widget.currentUser,
        ));
    _controller.clear();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
            Text(widget.room == 'global' ? 'Community Chat' : 'Chat Room',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18.sp)),
            Text('Online members',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0.5,
        foregroundColor: isDark ? Colors.white : AppColors.textHeadline,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());
                }
              },
              builder: (context, state) {
                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 64.w,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.2)),
                          SizedBox(height: 16.h),
                          Text('No messages yet.\nStart the conversation!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 16.sp,
                                  height: 1.4)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderName == widget.currentUser;
                      return _buildMessageBubble(msg, isMe, isDark);
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
              child: Text(
                msg.senderName,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              gradient: isMe ? AppColors.primaryGradient : null,
              color:
                  isMe ? null : (isDark ? AppColors.darkSurface : Colors.white),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
                bottomLeft:
                    isMe ? Radius.circular(20.r) : const Radius.circular(0),
                bottomRight:
                    isMe ? const Radius.circular(0) : Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Text(
              msg.content,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.textHeadline),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 12.h,
          bottom: MediaQuery.of(context).padding.bottom + 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : Colors.grey[100],
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                    color: isDark ? Colors.white10 : Colors.transparent),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 15.sp),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              height: 48.w,
              width: 48.w,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 22.w),
            ),
          ),
        ],
      ),
    );
  }
}
