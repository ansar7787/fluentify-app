import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/agora_service.dart';

class VideoCallPage extends StatefulWidget {
  final String channelName;
  final String token;
  final int userId;
  final String mentorName;

  const VideoCallPage({
    super.key,
    required this.channelName,
    required this.token,
    required this.userId,
    required this.mentorName,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final agoraService = AgoraService();
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  List<int> remoteUids = [];
  late RtcEngineEventHandler _rtcEngineEventHandler;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
  }

  Future<void> _initializeAgora() async {
    // Ideally fetch App ID from config/env
    // Using a placeholder or the one from config if available
    const appId = AppConstants.agoraAppId;

    await agoraService.initialize(appId);

    _rtcEngineEventHandler = RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        debugPrint('Local user joined: ${connection.localUid}');
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        debugPrint('Remote user joined: $remoteUid');
        setState(() {
          remoteUids.add(remoteUid);
        });
      },
      onUserOffline: (connection, remoteUid, reason) {
        debugPrint('Remote user offline: $remoteUid');
        setState(() {
          remoteUids.removeWhere((uid) => uid == remoteUid);
        });
      },
    );

    await agoraService.setEventHandler(_rtcEngineEventHandler);

    await agoraService.joinChannel(
      token: widget.token,
      channelName: widget.channelName,
      userId: widget.userId,
    );
  }

  @override
  void dispose() {
    agoraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Call with ${widget.mentorName}'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Main video view (Remote)
          if (remoteUids.isNotEmpty)
            AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: agoraService.engine,
                canvas: VideoCanvas(uid: remoteUids[0]),
              ),
            )
          else
            const Center(
              child: Text(
                'Waiting for mentor to join...',
                style: TextStyle(color: Colors.white),
              ),
            ),

          // Local video preview
          Positioned(
            top: 20,
            right: 20,
            child: SizedBox(
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: agoraService.engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),

          // Controls
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () async {
                      setState(() => _isAudioEnabled = !_isAudioEnabled);
                      await agoraService.enableLocalAudio(_isAudioEnabled);
                    },
                    icon: Icon(
                      _isAudioEnabled ? Icons.mic : Icons.mic_off,
                      color: _isAudioEnabled ? Colors.white : Colors.red,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: _isAudioEnabled
                          ? Colors.white24
                          : Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // End call logic
                    },
                    icon: const Icon(Icons.call_end,
                        color: Colors.white, size: 32),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      setState(() => _isVideoEnabled = !_isVideoEnabled);
                      await agoraService.enableLocalVideo(_isVideoEnabled);
                    },
                    icon: Icon(
                      _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                      color: _isVideoEnabled ? Colors.white : Colors.red,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: _isVideoEnabled
                          ? Colors.white24
                          : Colors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  IconButton(
                    onPressed: () => agoraService.switchCamera(),
                    icon: const Icon(Icons.switch_camera,
                        color: Colors.white, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
