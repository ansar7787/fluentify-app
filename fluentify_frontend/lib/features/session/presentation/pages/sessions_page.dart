import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Use the new proper Session Clean Arch
import '../../domain/entities/session_entity.dart';
import '../bloc/session_bloc.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../../peer/presentation/pages/call_page.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SessionBloc>()..add(LoadSessions()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('My Sessions',
              style: TextStyle(
                  color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppTheme.accentBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.accentBlue,
            indicatorWeight: 3,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, state) {
            if (state is SessionLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SessionLoaded) {
              // Filter sessions
              final now = DateTime.now();
              final upcoming = state.sessions
                  .where((b) =>
                      b.scheduledAt.isAfter(now) && b.status != 'cancelled')
                  .toList();
              final history = state.sessions
                  .where((b) =>
                      b.scheduledAt.isBefore(now) || b.status == 'cancelled')
                  .toList();

              // Sort
              upcoming.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
              history.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildSessionList(upcoming, isUpcoming: true),
                  _buildSessionList(history, isUpcoming: false),
                ],
              );
            } else if (state is SessionError) {
              return Center(
                  child: Text("Failed to load sessions: ${state.message}"));
            }
            return const Center(child: Text("No sessions found."));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Navigate to Mentor/Booking find page
            // e.g. Navigator.pushNamed(context, '/mentors');
          },
          backgroundColor: AppTheme.accentBlue,
          icon: const Icon(Icons.add_rounded),
          label: const Text("Book New"),
        ),
      ),
    );
  }

  Widget _buildSessionList(List<SessionEntity> sessions,
      {required bool isUpcoming}) {
    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                isUpcoming
                    ? Icons.event_busy_rounded
                    : Icons.history_edu_rounded,
                size: 60,
                color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? "No upcoming sessions" : "No session history",
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(context, session, isUpcoming)
            .animate(delay: (index * 100).ms)
            .fadeIn()
            .slideY();
      },
    );
  }

  Widget _buildSessionCard(
      BuildContext context, SessionEntity session, bool isUpcoming) {
    // Pass context for navigation
    final date = DateFormat('MMM d, y').format(session.scheduledAt);
    final time = DateFormat('jm').format(session.scheduledAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isUpcoming
                  ? AppTheme.accentBlue.withValues(alpha: 0.1)
                  : Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded,
                        color: isUpcoming ? AppTheme.accentBlue : Colors.grey,
                        size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "$date • $time",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isUpcoming ? AppTheme.accentBlue : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${session.durationMinutes} min",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                )
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: session.mentorAvatar.isNotEmpty
                      ? NetworkImage(session.mentorAvatar)
                      : null,
                  child: session.mentorAvatar.isNotEmpty
                      ? null
                      : const Icon(Icons.person_rounded,
                          size: 32, color: Colors.grey),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        "with ${session.mentorName}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: session.status == 'active'
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Button
                if (isUpcoming)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CallPage(
                                    channelId:
                                        session.meetingId ?? 'demo_channel',
                                    token: '',
                                    uid: 0,
                                    peerName: session.mentorName,
                                    currentUserName: "Me",
                                  )));
                    },
                    child: const Text("Join",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
