import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();

  factory AgoraService() => _instance;

  AgoraService._internal();

  late RtcEngine _engine;
  bool _isInitialized = false;

  Future<void> initialize(String appId) async {
    if (_isInitialized) return;

    _engine = createAgoraRtcEngine();

    await _engine.initialize(RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await _engine.enableVideo();
    await _engine.startPreview(); // Optional: Start preview immediately
    await _engine.enableAudio();
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.setDefaultAudioRouteToSpeakerphone(true);

    _isInitialized = true;
  }

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int userId,
  }) async {
    if (!_isInitialized) {
      throw Exception('Agora not initialized');
    }

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: userId,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  Future<void> leaveChannel() async {
    if (!_isInitialized) return;

    await _engine.leaveChannel();
  }

  Future<void> enableLocalAudio(bool enabled) async {
    if (!_isInitialized) return;

    await _engine.enableLocalAudio(enabled);
  }

  Future<void> enableLocalVideo(bool enabled) async {
    if (!_isInitialized) return;

    await _engine.enableLocalVideo(enabled);
  }

  Future<void> switchCamera() async {
    if (!_isInitialized) return;

    await _engine.switchCamera();
  }

  Future<void> setEventHandler(RtcEngineEventHandler eventHandler) async {
    if (!_isInitialized) return;

    _engine.registerEventHandler(eventHandler);
  }

  Future<void> dispose() async {
    if (!_isInitialized) return;

    await _engine.leaveChannel();
    await _engine.release();

    _isInitialized = false;
  }

  RtcEngine get engine => _engine;
  bool get isInitialized => _isInitialized;
}
