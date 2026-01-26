import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../../user/presentation/bloc/user_event.dart';
import '../bloc/peer_bloc.dart';
import '../bloc/peer_event.dart';
import '../bloc/peer_state.dart';
import 'call_page.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();

    // Get current user from UserBloc state
    // Ideally user is already loaded when reaching this page
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<PeerBloc>().add(JoinPeerQueue(userState.user));
    } else {
      // Handle edge case or trigger load
      context.read<UserBloc>().add(GetUserProfileEvent());
      // Listen for load? For MVP assuming loaded.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PeerBloc, PeerState>(
      listener: (context, state) {
        if (state is PeerMatched) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CallPage(
                channelId: state.channelId,
                token: state.token,
                uid: state.uid,
                peerName: state.peerName,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Radar Effect
                  ...List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: 150 + (index * 50) * _controller.value,
                          height: 150 + (index * 50) * _controller.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blueAccent
                                  .withValues(alpha: 1 - _controller.value),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.public, size: 60, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const Text(
                'Finding a peer...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Connecting you with someone at your level',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              OutlinedButton(
                onPressed: () {
                  context.read<PeerBloc>().add(LeavePeerQueue());
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
