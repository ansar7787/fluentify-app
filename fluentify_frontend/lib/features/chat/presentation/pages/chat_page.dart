import 'package:flutter/material.dart';
import '../../../../../core/services/socket_service.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final SocketService _socketService = SocketService();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Initialize socket/join room
    _socketService.initSocket(widget.currentUserId);

    // Listen
    _socketService.listenForMessages((data) {
      if (mounted) {
        setState(() {
          _messages.add({
            'content': data['content'],
            'sender_id': data['sender'][
                'id'], // Assuming populated or just sender_id depending on backend
            'isMe': false,
          });
        });
      }
    });

    _socketService.listenForMessageSent((data) {
      if (mounted) {
        setState(() {
          // Confirm sent, maybe update status or just rely on local add
          // If we added locally optimistically, we might not need this
        });
      }
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final content = _controller.text.trim();

    // Optimistic UI update
    setState(() {
      _messages.add({
        'content': content,
        'sender_id': widget.currentUserId,
        'isMe': true,
      });
    });

    _socketService.sendMessage(
        widget.currentUserId, widget.otherUserId, content);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight:
                            isMe ? Radius.zero : const Radius.circular(16),
                        bottomLeft:
                            isMe ? const Radius.circular(16) : Radius.zero,
                      ),
                    ),
                    child: Text(
                      msg['content'],
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
