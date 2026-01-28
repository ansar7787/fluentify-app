import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../user/presentation/bloc/user_bloc.dart';
import '../../../../user/presentation/bloc/user_state.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({super.key});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        int streakCount = 0;
        if (state is UserLoaded) {
          streakCount = state.user.streakCount;
        }

        // Generate data for the path
        final totalDays = 30; // Show a 30-day path for now
        final currentDay = streakCount % 30 == 0 ? 1 : streakCount % 30;

        return Scaffold(
          backgroundColor: const Color(0xFFCFF1F6), // Light Cyan bg
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF00838F)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Streak Master",
              style: TextStyle(
                  color: const Color(0xFF00838F),
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              // Background decorative elements
              Positioned(
                top: 50.h,
                left: 20.w,
                child: Icon(Icons.star_rounded,
                    color: Colors.white.withOpacity(0.4), size: 40.sp),
              ),
              Positioned(
                bottom: 150.h,
                right: 30.w,
                child: Icon(Icons.star_rounded,
                    color: Colors.white.withOpacity(0.4), size: 60.sp),
              ),

              // The Path List
              ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                itemCount: totalDays,
                reverse: true, // Start from bottom (Day 1)
                itemBuilder: (context, index) {
                  final day = index + 1;
                  // Calculate zigzag position
                  // 0 -> center, 1 -> right, 2 -> center, 3 -> left ... pattern
                  double alignX = 0;
                  if (day % 4 == 1) alignX = 0; // Center
                  if (day % 4 == 2) alignX = 0.5; // Right
                  if (day % 4 == 3) alignX = 0; // Center
                  if (day % 4 == 0) alignX = -0.5; // Left

                  bool isCompleted = day <= streakCount;
                  bool isCurrent = day == streakCount + 1;
                  bool isFuture = day > streakCount + 1;

                  return _buildPathNode(
                      day, alignX, isCompleted, isCurrent, isFuture);
                },
              ),

              // Floating Info Card (Static for now, could be dynamic)
              if (streakCount > 0)
                Positioned(
                  top: 100.h,
                  right: 40.w,
                  child: _buildInfoCard(streakCount),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPathNode(
      int day, double alignX, bool isCompleted, bool isCurrent, bool isFuture) {
    // Offset for zigzag
    return Align(
      alignment: Alignment(alignX, 0),
      child: Column(
        children: [
          // Dashed Line Connector (simplified)
          if (day >
              1) // Don't show line below day 1 (since list is reversed? wait list is reversed meaning index 0 is Day 1 (bottom).
            // Actually list is reversed so index 0 is Day 1.
            // But we want Day 1 at bottom.
            // If reverse: true, index 0 is at bottom of screen.
            // So day 1 is at bottom. Line should go UP to day 2.
            // In ListView, item index+1 is visually above item index.
            // So we need line ABOVE this node?
            // Actually, let's just draw the node. The line logic is complex in ListView.
            // A simpler approach: CustomPaint for lines, but for now let's just use Container lines.
            // Since it's a zigzag, vertical lines don't look great.
            // Let's rely on spacing.
            SizedBox(height: 20.h),

          GestureDetector(
            onTap: () {
              // Show details for day
            },
            child: Container(
              width: 80.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF00ACC1) // Cyan 600
                    : (isCurrent
                        ? const Color(0xFF00ACC1)
                        : const Color(0xFF00ACC1).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  if (isCompleted || isCurrent)
                    BoxShadow(
                      color: const Color(0xFF00838F).withOpacity(0.4),
                      offset: const Offset(0, 6),
                      blurRadius: 0, // Solid shadow style
                    )
                ],
                border: isCurrent
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Day",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "$day",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate(target: isCurrent ? 1 : 0)
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                  duration: 1000.ms,
                  curve: Curves.easeInOut)
              .then()
              .scale(
                  begin: const Offset(1.1, 1.1),
                  end: const Offset(1.0, 1.0),
                  duration: 1000.ms),
        ],
      ),
    );
  }

  Widget _buildInfoCard(int streakCount) {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: 200.w,
      decoration: BoxDecoration(
        color: const Color(0xFF00838F),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Current Streak",
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
          Text(
            "$streakCount Days 🔥",
            style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold),
          ),
          Divider(color: Colors.white.withOpacity(0.2)),
          Text(
            "Keep it up to verify your discipline!",
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
