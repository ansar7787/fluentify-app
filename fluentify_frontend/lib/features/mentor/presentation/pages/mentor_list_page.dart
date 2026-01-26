import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/mentor_bloc.dart';
import '../bloc/mentor_event.dart';
import '../bloc/mentor_state.dart';
import 'booking_page.dart';

class MentorListPage extends StatefulWidget {
  const MentorListPage({super.key});

  @override
  State<MentorListPage> createState() => _MentorListPageState();
}

class _MentorListPageState extends State<MentorListPage> {
  String selectedLanguage = '';

  @override
  void initState() {
    super.initState();
    // Fetch mentors on load
    context.read<MentorBloc>().add(const GetAllMentorsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Mentors'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<MentorBloc, MentorState>(
              builder: (context, state) {
                if (state is MentorLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MentorError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                if (state is AllMentorsLoaded) {
                  if (state.mentors.isEmpty) {
                    return const Center(child: Text('No mentors found'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.mentors.length,
                    itemBuilder: (context, index) {
                      final mentor = state.mentors[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mentor.specialization,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 16),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${mentor.averageRating} (${mentor.totalReviews} reviews)',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '\$${mentor.hourlyRate}/hr',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                mentor.bio,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: mentor.languages
                                    .map((lang) => Chip(label: Text(lang)))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BookingPage(
                                          mentorId: mentor.id,
                                          mentorName:
                                              'Mentor', // Ideally fetch user name
                                          hourlyRate: mentor.hourlyRate,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Book Session'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('English'),
            const SizedBox(width: 8),
            _filterChip('Spanish'),
            const SizedBox(width: 8),
            _filterChip('French'),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: selectedLanguage == label,
      onSelected: (selected) {
        setState(() {
          selectedLanguage = selected ? label : '';
        });
        context
            .read<MentorBloc>()
            .add(GetAllMentorsRequested(language: selectedLanguage));
      },
    );
  }
}
