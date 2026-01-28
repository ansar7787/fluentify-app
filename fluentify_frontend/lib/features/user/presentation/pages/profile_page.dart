import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';

import '../../../../config/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetUserProfileEvent());
    context.read<LeaderboardBloc>().add(const GetLeaderboardEvent());
  }

  Future<void> _pickAndUploadImage(String userId) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      final storageService = getIt<FirebaseStorageService>();
      final imageUrl = await storageService.uploadProfileImage(
        File(image.path),
        userId,
      );

      if (imageUrl != null) {
        if (mounted) {
          context
              .read<UserBloc>()
              .add(UpdateUserProfileEvent(avatarUrl: imageUrl));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile picture updated successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to upload image. Please try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? Colors.black : Colors.white;
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          _buildBackgroundAuroras(isDark),
          MultiBlocListener(
            listeners: [
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthUnauthenticated) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  }
                },
              ),
              BlocListener<UserBloc, UserState>(
                listener: (context, state) {
                  if (state is UserError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return _buildSkeleton(context, isDark);
                } else if (state is UserLoaded) {
                  final user = state.user;
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildSliverHeader(user, textColor, isDark),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            SizedBox(height: 24.h),
                            _buildStatsGrid(user, textColor)
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.2),
                            SizedBox(height: 32.h),
                            _buildSectionHeader('Learning Journey',
                                    Icons.auto_graph_rounded, textColor)
                                .animate()
                                .fadeIn(delay: 200.ms),
                            SizedBox(height: 16.h),
                            _buildProgressSection(user, textColor)
                                .animate()
                                .fadeIn(delay: 300.ms)
                                .scale(begin: const Offset(0.9, 0.9)),
                            SizedBox(height: 32.h),
                            if (user.subscriptionPlan == 'free')
                              _buildPremiumUpgradeCard(context)
                                  .animate()
                                  .fadeIn(delay: 350.ms)
                                  .shimmer(
                                      duration: 2.seconds,
                                      color: Colors.white24),
                            SizedBox(height: 32.h),
                            _buildSectionHeader('Settings & More',
                                    Icons.settings_rounded, textColor)
                                .animate()
                                .fadeIn(delay: 400.ms),
                            SizedBox(height: 16.h),
                            _buildSettingsSection(user, textColor, isDark)
                                .animate()
                                .fadeIn(delay: 500.ms)
                                .slideY(begin: 0.1),
                            SizedBox(height: 100.h),
                          ]),
                        ),
                      ),
                    ],
                  );
                } else if (state is UserError) {
                  return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: Colors.white)));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundAuroras(bool isDark) {
    return Stack(
      children: [
        Positioned(
          top: -100.h,
          right: -50.w,
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  AppTheme.primaryYellow.withValues(alpha: isDark ? 0.2 : 0.1),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.5, 1.5),
                  duration: 10.seconds)
              .moveX(begin: 0, end: 50.w),
        ),
        Positioned(
          top: 200.h,
          left: -100.w,
          child: Container(
            width: 400.w,
            height: 400.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  AppTheme.accentBlue.withValues(alpha: isDark ? 0.15 : 0.08),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 12.seconds)
              .moveY(begin: 0, end: -30.h),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildSliverHeader(user, Color textColor, bool isDark) {
    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      backgroundColor: Colors.transparent,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40.h),
            Stack(
              alignment: Alignment.center,
              children: [
                _buildAvatarHalo(isDark)
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: 20.seconds),
                Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: textColor.withValues(alpha: 0.1), width: 2.w),
                    ),
                    child: CircleAvatar(
                      radius: 55.w,
                      backgroundColor:
                          isDark ? AppTheme.cardBg : Colors.grey[200],
                      backgroundImage: user.profileImage != null
                          ? CachedNetworkImageProvider(user.profileImage!)
                          : null,
                      child: _isUploading
                          ? const CircularProgressIndicator(
                              color: AppTheme.primaryYellow)
                          : (user.profileImage == null
                              ? Text(user.fullName[0].toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 44.sp,
                                      color: textColor,
                                      fontWeight: FontWeight.bold))
                              : null),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _pickAndUploadImage(user.id),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                          color: AppTheme.primaryYellow,
                          shape: BoxShape.circle),
                      child: Icon(Icons.edit_rounded,
                          color: Colors.black, size: 20.w),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              user.fullName,
              style: TextStyle(
                color: textColor,
                fontSize: 26.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryYellow, Color(0xFFFFA000)],
                ),
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryYellow.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'LEVEL ${user.level}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarHalo(bool isDark) {
    return Container(
      width: 140.w,
      height: 140.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            AppTheme.primaryYellow,
            AppTheme.accentBlue,
            AppTheme.secondaryGreen,
            AppTheme.primaryYellow,
          ],
          stops: [0, 0.33, 0.66, 1],
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(user, Color textColor) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        String rank = "...";
        if (state is LeaderboardLoaded) {
          final index = state.rankings.indexWhere((u) => u.id == user.id);
          rank = index != -1 ? '#${index + 1}' : 'Unranked';
        }

        return Row(
          children: [
            Expanded(
              child: _buildGlassStatCard(
                'COINS',
                user.coins.toString(),
                Icons.toll_rounded,
                AppTheme.primaryYellow,
                textColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildGlassStatCard(
                'STREAK',
                user.streakCount.toString(),
                Icons.local_fire_department_rounded,
                Colors.orangeAccent,
                textColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildGlassStatCard(
                'RANK',
                rank,
                Icons.emoji_events_rounded,
                AppTheme.accentBlue,
                textColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGlassStatCard(
      String label, String value, IconData icon, Color color, Color textColor) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100.h,
      borderRadius: 20.r,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
          stops: const [
            0.1,
            1
          ]),
      borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.5),
            color.withValues(alpha: 0.2),
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
                color: textColor, fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(
                color: textColor.withValues(alpha: 0.5),
                fontSize: 10.sp,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: textColor.withValues(alpha: 0.3), size: 20.w),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(user, Color textColor) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 280.h,
      borderRadius: 24.r,
      blur: 15,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            textColor.withValues(alpha: 0.1),
            textColor.withValues(alpha: 0.05),
          ]),
      borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            textColor.withValues(alpha: 0.2),
            textColor.withValues(alpha: 0.1),
          ]),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Progress',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text('${user.missionsCompleted} Missions Completed',
                        style: TextStyle(
                            color: textColor.withValues(alpha: 0.5),
                            fontSize: 14.sp)),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGreen.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.rocket_launch_rounded,
                      color: AppTheme.secondaryGreen, size: 24.w),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            Expanded(child: _buildBarChart(user.missionsCompleted, textColor)),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ChartLabel('Mon', textColor),
                _ChartLabel('Tue', textColor),
                _ChartLabel('Wed', textColor),
                _ChartLabel('Thu', textColor),
                _ChartLabel('Fri', textColor),
                _ChartLabel('Sat', textColor),
                _ChartLabel('Sun', textColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(int totalMissions, Color textColor) {
    // Generate simple dynamic chart based on total missions
    final data = [
      (totalMissions * 0.1).clamp(1.0, 10.0),
      (totalMissions * 0.2).clamp(2.0, 12.0),
      (totalMissions * 0.15).clamp(1.0, 8.0),
      (totalMissions * 0.3).clamp(3.0, 15.0),
      (totalMissions * 0.4).clamp(4.0, 18.0),
      (totalMissions * 0.25).clamp(2.0, 10.0),
      (totalMissions * 0.5).clamp(5.0, 20.0),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: 20,
        barTouchData: BarTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i],
                color: i == 6
                    ? AppTheme.primaryYellow
                    : textColor.withValues(alpha: 0.2),
                width: 12.w,
                borderRadius: BorderRadius.circular(6.r),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 20,
                  color: textColor.withValues(alpha: 0.05),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPremiumUpgradeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child:
                    Icon(Icons.star_rounded, color: Colors.white, size: 24.w),
              ),
              SizedBox(width: 12.w),
              Text(
                'Unlock Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Get unlimited AI practice, detailed pronunciation feedback, and remove all ads.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 14.sp),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/subscription'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r)),
            ),
            child: Text('Upgrade Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(UserEntity user, Color textColor, bool isDark) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 480.h, // Increased height to accommodate Admin tile
      borderRadius: 24.r,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            textColor.withValues(alpha: 0.05),
            textColor.withValues(alpha: 0.02),
          ]),
      borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            textColor.withValues(alpha: 0.1),
            textColor.withValues(alpha: 0.05),
          ]),
      child: Column(
        children: [
          _buildSettingsTile('Personal Profile', Icons.person_rounded,
              Colors.purpleAccent, textColor,
              onTap: () => Navigator.pushNamed(context, '/personal_profile')),
          _buildSettingsTile('Learning Goals', Icons.flag_rounded,
              Colors.orangeAccent, textColor,
              onTap: () => Navigator.pushNamed(context, '/learning_goals')),
          _buildSettingsTile('Subscription', Icons.star_rounded,
              AppTheme.primaryYellow, textColor,
              onTap: () => Navigator.pushNamed(context, '/subscription')),
          // Conditionally render Admin Dashboard
          if (user.role == 'admin')
            _buildSettingsTile('Admin Dashboard',
                Icons.admin_panel_settings_rounded, Colors.redAccent, textColor,
                onTap: () => Navigator.pushNamed(context, '/admin_dashboard')),
          _buildSettingsTile('Notifications', Icons.notifications_rounded,
              Colors.blueAccent, textColor,
              onTap: () => Navigator.pushNamed(context, '/notifications')),
          _buildSettingsTile('Dark Mode', Icons.dark_mode_rounded,
              Colors.indigoAccent, textColor,
              trailing: Switch(
                value: isDark,
                activeThumbColor: AppTheme.primaryYellow,
                onChanged: (value) =>
                    context.read<ThemeCubit>().toggleTheme(value),
              )),
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: ElevatedButton(
              onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r)),
                minimumSize: Size(double.infinity, 48.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 20.w),
                  SizedBox(width: 8.w),
                  Text('Logout',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      String title, IconData icon, Color color, Color textColor,
      {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: color, size: 22.w),
      ),
      title: Text(
        title,
        style: TextStyle(
            color: textColor, fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded,
              color: textColor.withValues(alpha: 0.2), size: 22.w),
    );
  }

  Widget _buildSkeleton(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? Colors.black : Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppShimmer.circle(size: 110.w),
            SizedBox(height: 24.h),
            AppShimmer.rect(width: 150.w, height: 28.h),
            SizedBox(height: 48.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppShimmer.rect(width: 80.w, height: 80.w, borderRadius: 20.r),
                SizedBox(width: 12.w),
                AppShimmer.rect(width: 80.w, height: 80.w, borderRadius: 20.r),
                SizedBox(width: 12.w),
                AppShimmer.rect(width: 80.w, height: 80.w, borderRadius: 20.r),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLabel extends StatelessWidget {
  final String label;
  final Color textColor;
  const _ChartLabel(this.label, this.textColor);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
          color: textColor.withValues(alpha: 0.3),
          fontSize: 10.sp,
          fontWeight: FontWeight.w600),
    );
  }
}
