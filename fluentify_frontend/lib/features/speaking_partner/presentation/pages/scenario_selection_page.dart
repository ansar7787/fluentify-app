import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/speaking_partner_bloc.dart';
import '../bloc/speaking_partner_event.dart';
import '../bloc/speaking_partner_state.dart';
import 'speaking_partner_chat_page.dart';

class ScenarioSelectionPage extends StatefulWidget {
  const ScenarioSelectionPage({super.key});

  @override
  State<ScenarioSelectionPage> createState() => _ScenarioSelectionPageState();
}

class _ScenarioSelectionPageState extends State<ScenarioSelectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<SpeakingPartnerBloc>().add(LoadScenarios());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text('Speaking Partner',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22.sp)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<SpeakingPartnerBloc, SpeakingPartnerState>(
        builder: (context, state) {
          if (state is ScenariosLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScenariosLoaded) {
            return ListView.builder(
              padding: EdgeInsets.all(20.w),
              itemCount: state.scenarios.length,
              itemBuilder: (context, index) {
                final scenario = state.scenarios[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: _buildScenarioCard(scenario, isDark),
                );
              },
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
          } else if (state is SpeakingPartnerError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildScenarioCard(dynamic scenario, bool isDark) {
    return GestureDetector(
      onTap: () {
        context.read<SpeakingPartnerBloc>().add(StartConversation(scenario));
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SpeakingPartnerChatPage(scenario: scenario)),
        );
      },
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          image: DecorationImage(
            image: NetworkImage(scenario.image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(scenario.difficulty)
                      .withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  scenario.difficulty,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                scenario.title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                scenario.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}
