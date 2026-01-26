import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AdminBloc>()..add(GetAdminStatsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // We'll handle refresh via Bloc in the body if needed,
                // or we can make this stateless widget stateful to access context,
                // but for now, the BlocProvider creates it on load.
                // A cleaner way is using a Builder or separate widget to access context.
              },
            ),
          ],
        ),
        body: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AdminError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is AdminStatsLoaded) {
              final stats = state.stats;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatCard(context, 'Total Users',
                            '${stats.totalUsers}', Icons.people, Colors.blue),
                        _buildStatCard(
                            context,
                            'Active Mentors',
                            '${stats.activeMentors}',
                            Icons.school,
                            Colors.green),
                        _buildStatCard(
                            context,
                            'Sessions',
                            '${stats.totalSessions}',
                            Icons.video_call,
                            Colors.orange),
                        _buildStatCard(
                            context,
                            'Pending Mentors', // Replaced Revenue with Pending Mentors as per API
                            '${stats.pendingMentors}',
                            Icons.verified_user,
                            Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Management',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300)),
                          leading: const Icon(Icons.person_outline),
                          title: const Text('Manage Users'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navigate to Manage Users
                          },
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300)),
                          leading: const Icon(Icons.verified_user_outlined),
                          title: const Text('Mentor Approvals'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text('${stats.pendingMentors}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                          ),
                          onTap: () {
                            // Navigate to Mentor Approvals
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Loading Admin Stats...'));
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
