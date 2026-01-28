import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../chat/presentation/pages/chat_page.dart';

class CallPage extends StatefulWidget {
  final String channelId;
  final String token;
  final int uid;
  final String peerName;
  final String currentUserName;

  const CallPage({
    super.key,
    required this.channelId,
    required this.token,
    required this.uid,
    required this.peerName,
    required this.currentUserName,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  // Replace with your App ID
  static const String appId = "YOUR_AGORA_APP_ID";
  late RtcEngine _engine;
  bool _remoteUserJoined = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // Retrieve permissions
    await [Permission.microphone].request();

    // Create RtcEngine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          if (mounted) {
            // No-op for local user join visual update for now
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          if (mounted) {
            setState(() {
              _remoteUserJoined = true;
            });
          }
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          if (mounted) {
            setState(() {
              _remoteUserJoined = false;
              // Maybe end call automatically?
              Navigator.pop(context);
            });
          }
        },
      ),
    );

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelId,
      uid: widget.uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
  }

  void _onEndCall() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child:
                        const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.peerName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _remoteUserJoined ? 'Connected' : 'Connecting...',
                    style: TextStyle(
                      color: _remoteUserJoined
                          ? Colors.greenAccent
                          : Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallControl(
                    icon: _muted ? Icons.mic_off : Icons.mic,
                    color: _muted ? Colors.white : Colors.blueAccent,
                    onTap: _onToggleMute,
                  ),
                  _buildCallControl(
                    icon: Icons.call_end,
                    color: Colors.redAccent,
                    isLarge: true,
                    onTap: _onEndCall,
                  ),
                  _buildCallControl(
                    icon: Icons.chat_bubble_rounded,
                    color: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            room: widget.channelId,
                            currentUser: widget.currentUserName,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallControl({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 24 : 16),
        decoration: BoxDecoration(
          color: isLarge ? Colors.redAccent : Colors.white10,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: isLarge ? Colors.white : color, size: isLarge ? 32 : 24),
      ),
    );
  }
}
