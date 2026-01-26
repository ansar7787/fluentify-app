import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_theme.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_state.dart';

class PersonalProfilePage extends StatelessWidget {
  const PersonalProfilePage({super.key});

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
          'Personal Profile',
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoaded) {
            final user = state.user;
            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  _buildInfoTile('Full Name', user.fullName,
                      Icons.person_outline_rounded, textColor),
                  _buildInfoTile(
                      'Email', user.email, Icons.email_rounded, textColor),
                  _buildInfoTile(
                      'Account Type',
                      user.subscriptionPlan.toUpperCase(),
                      Icons.star_outline_rounded,
                      textColor),
                  _buildInfoTile('Level', user.level.toString(),
                      Icons.trending_up_rounded, textColor),
                ],
              ),
            );
          }
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryYellow));
        },
      ),
    );
  }

  Widget _buildInfoTile(
      String label, String value, IconData icon, Color textColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryYellow, size: 22.w),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: textColor.withValues(alpha: 0.5), fontSize: 12.sp),
              ),
              Text(
                value,
                style: TextStyle(
                    color: textColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
