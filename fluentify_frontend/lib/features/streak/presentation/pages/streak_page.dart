import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';

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

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Line to NEXT node (if exists)
                      if (day < totalDays)
                        CustomPaint(
                          painter: StreakLinePainter(
                            isRightToLeft: day % 2 == 0,
                            isCompleted: day <
                                streakCount, // Line is completed if both nodes are completed
                          ),
                          child: SizedBox(height: 80.h, width: 200.w),
                        ),

                      _buildPathNode(
                          day, alignX, isCompleted, isCurrent, isFuture),
                    ],
                  );
                },
              ),

              // Floating Info Card
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
    return Align(
      alignment: Alignment(alignX, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 70.w,
          height: 70.w, // Circle
          margin: EdgeInsets.symmetric(vertical: 5.h), // Spacing for lines
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFF0D9488) // Teal-ish for done
                : (isCurrent
                    ? const Color(0xFFF97316) // Orange for current
                    : Colors.white),
            border: Border.all(
                color: isCurrent
                    ? Colors.white
                    : (isCompleted
                        ? const Color(0xFF0F766E)
                        : Colors.grey.shade300),
                width: isCurrent ? 4 : 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Center(
            child:
                isCompleted // && !isCurrent ? NO, Day 1 done means check mark
                    ? (day <= 0
                        ? Text("$day")
                        : Icon(Icons.check, color: Colors.white, size: 30.sp))
                    : Text(
                        "$day",
                        style: TextStyle(
                          color: isFuture ? Colors.grey : Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
          ),
        )
            .animate(target: isCurrent ? 1 : 0)
            .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15)),
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

class StreakLinePainter extends CustomPainter {
  final bool isRightToLeft;
  final bool isCompleted;

  StreakLinePainter({required this.isRightToLeft, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    // Basic Vertical Line for now to prevent breaking build with complex math
    final paint = Paint()
      ..color = isCompleted ? const Color(0xFF0D9488) : Colors.grey.shade300
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw a simple dashed or solid line connecting vaguely
    // Center Bottom to Center Top
    Path path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width / 2, 0);

    // Zigzag logic is hard in strict ListViews, simplified to a vertical connector
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
