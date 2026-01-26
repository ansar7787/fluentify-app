import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/theme/app_theme.dart';

class LearningGoalsPage extends StatelessWidget {
  const LearningGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? Colors.black : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textColor, size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Learning Goals',
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What do you want to achieve?',
              style: TextStyle(
                  color: textColor,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Set goals to stay motivated and track your progress.',
              style: TextStyle(
                  color: textColor.withValues(alpha: 0.5), fontSize: 14.sp),
            ),
            SizedBox(height: 32.h),
            _buildGoalCard('Fluency', 'Speak naturally without pauses',
                Icons.speed_rounded, Colors.blueAccent, textColor),
            _buildGoalCard('Vocabulary', 'Learn 1000+ new words',
                Icons.menu_book_rounded, Colors.orangeAccent, textColor),
            _buildGoalCard(
                'Pronunciation',
                'Master native accents',
                Icons.record_voice_over_rounded,
                Colors.purpleAccent,
                textColor),
            _buildGoalCard('Confidence', 'Talk to anyone, anywhere',
                Icons.auto_awesome_rounded, Colors.tealAccent, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(String title, String subtitle, IconData icon,
      Color color, Color textColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: textColor.withValues(alpha: 0.05), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.w),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: textColor.withValues(alpha: 0.5), fontSize: 13.sp),
                ),
              ],
            ),
          ),
          Checkbox(
            value: false,
            onChanged: (v) {},
            activeColor: AppTheme.primaryYellow,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.r)),
          ),
        ],
      ),
    );
  }
}
