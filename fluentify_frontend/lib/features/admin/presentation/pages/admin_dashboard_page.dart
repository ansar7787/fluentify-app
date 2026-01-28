import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/theme/app_theme.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Admin Dashboard",
            style: TextStyle(color: Colors.white, fontSize: 20.sp)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings_rounded,
                  size: 80.w, color: AppTheme.primaryYellow),
              SizedBox(height: 20.h),
              Text("Welcome Admin!",
                  style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              SizedBox(height: 10.h),
              Text(
                "Level Manager & Content Editor coming soon.\nYou can manage Game Levels, Users, and Content dynamically from here.",
                style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.games_rounded, "Game Levels",
                        "Manage all 8 game categories"),
                    Divider(color: Colors.white10),
                    _buildInfoRow(Icons.people_rounded, "Users",
                        "View and manage user accounts"),
                    Divider(color: Colors.white10),
                    _buildInfoRow(Icons.analytics_rounded, "Analytics",
                        "View app usage statistics"),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin_level_editor');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: Colors.black,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                ),
                child: const Text("Open Level Editor"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24.w),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp)),
              Text(subtitle,
                  style: TextStyle(color: Colors.white54, fontSize: 12.sp)),
            ],
          )
        ],
      ),
    );
  }
}
