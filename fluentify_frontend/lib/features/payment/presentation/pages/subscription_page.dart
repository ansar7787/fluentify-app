import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:ui';
import '../../../../config/theme/app_theme.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../../../user/presentation/bloc/user_bloc.dart';
import '../../../user/presentation/bloc/user_state.dart';
import '../../domain/entities/subscription_plan.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    context.read<PaymentBloc>().add(VerifyPaymentEvent(
          orderId: response.orderId!,
          paymentId: response.paymentId!,
          signature: response.signature!,
        ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Error: ${response.message}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        backgroundColor: AppTheme.accentBlue,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  void _startPayment(String orderId, int amount, String description) {
    var options = {
      'key': 'rzp_test_S6xVFDmyZdw8Qy',
      'amount': amount,
      'name': 'SpeakPay',
      'order_id': orderId,
      'description': description,
      'timeout': 300,
      'prefill': {
        'contact': '',
        'email': '',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
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
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentOrderCreated) {
                _startPayment(
                  state.order.id,
                  state.order.amount,
                  state.order.notes?['description'] ?? 'Premium Subscription',
                );
              } else if (state is PaymentSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(20.w),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r))),
                );
                Navigator.pop(context);
              } else if (state is PaymentFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(20.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                );
              }
            },
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(textColor),
                  Expanded(
                    child: BlocBuilder<UserBloc, UserState>(
                      builder: (context, userState) {
                        String currentPlan = 'free';
                        if (userState is UserLoaded) {
                          currentPlan = userState.user.subscriptionPlan;
                        }

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 8.h),
                          child: Column(
                            children: [
                              SizedBox(height: 20.h),
                              _buildPremiumHeader(textColor)
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .slideY(begin: 0.2),
                              SizedBox(height: 40.h),
                              ...SubscriptionPlan.defaultPlans.where((plan) {
                                final int currentLevel =
                                    SubscriptionPlan.defaultPlans
                                        .firstWhere(
                                          (p) => p.id == currentPlan,
                                          orElse: () =>
                                              SubscriptionPlan.defaultPlans[0],
                                        )
                                        .level;
                                return plan.level >= currentLevel &&
                                    (currentLevel == 0 || plan.level > 0);
                              }).map((plan) {
                                final bool isCurrent = currentPlan == plan.id;

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 24.h),
                                  child: Column(
                                    children: [
                                      _buildPlanCard(
                                        isDark: isDark,
                                        plan: plan,
                                        isActive: isCurrent,
                                        onTap: isCurrent
                                            ? null
                                            : () {
                                                context.read<PaymentBloc>().add(
                                                      CreatePaymentOrderEvent(
                                                        amount: plan.rawPrice
                                                            .toDouble(),
                                                        description:
                                                            'Fluentify ${plan.name} Subscription',
                                                      ),
                                                    );
                                              },
                                      )
                                          .animate()
                                          .fadeIn(delay: 200.ms)
                                          .slideY(begin: 0.1),
                                      if (isCurrent &&
                                          plan.id != 'free' &&
                                          userState is UserLoaded &&
                                          userState.user.subscriptionExpiry !=
                                              null)
                                        Padding(
                                          padding: EdgeInsets.only(top: 16.h),
                                          child: Text(
                                            'Next billing date: ${userState.user.subscriptionExpiry!.day}/${userState.user.subscriptionExpiry!.month}/${userState.user.subscriptionExpiry!.year}',
                                            style: TextStyle(
                                              color: textColor.withValues(
                                                  alpha: 0.5),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
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
          top: -50.h,
          left: -100.w,
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  AppTheme.primaryYellow.withValues(alpha: isDark ? 0.15 : 0.1),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.3, 1.3),
                  duration: 8.seconds)
              .moveX(begin: 0, end: 40.w),
        ),
        Positioned(
          bottom: 100.h,
          right: -150.w,
          child: Container(
            width: 400.w,
            height: 400.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6366F1)
                  .withValues(alpha: isDark ? 0.1 : 0.05),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.4, 1.4),
                  duration: 12.seconds)
              .moveY(begin: 0, end: -50.h),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _buildAppBar(Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close_rounded,
                color: textColor.withValues(alpha: 0.5), size: 24.w),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'Support',
            style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(Color textColor) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.star_rounded,
              color: AppTheme.primaryYellow, size: 48.w),
        ),
        SizedBox(height: 24.h),
        Text(
          'Elevate Your Learning',
          style: TextStyle(
            color: textColor,
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            'Master English 3x faster with our premium AI-powered features.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 16.sp,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard({
    required bool isDark,
    required SubscriptionPlan plan,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final Color textColor = isDark ? Colors.white : Colors.black;
    final bool isPremium = plan.id != 'free';
    final Color accentColor =
        isPremium ? const Color(0xFF6366F1) : textColor.withValues(alpha: 0.4);

    return GlassmorphicContainer(
      width: double.infinity,
      height: 480.h,
      borderRadius: 32.r,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isPremium
                ? const Color(0xFF6366F1)
                    .withValues(alpha: isDark ? 0.15 : 0.05)
                : textColor.withValues(alpha: 0.02),
            textColor.withValues(alpha: 0.01),
          ]),
      borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.3),
            accentColor.withValues(alpha: 0.1),
          ]),
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (plan.isPopular)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFFA855F7)]),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'POPULAR',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              plan.price,
              style: TextStyle(
                color: isPremium ? accentColor : textColor,
                fontSize: 36.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              plan.interval,
              style: TextStyle(
                  color: textColor.withValues(alpha: 0.4), fontSize: 14.sp),
            ),
            SizedBox(height: 32.h),
            const Divider(color: Colors.white10),
            SizedBox(height: 24.h),
            Expanded(
              child: ListView.builder(
                itemCount: plan.features.length,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: isPremium
                                ? const Color(0xFF2ECC71)
                                : Colors.grey,
                            size: 20.w),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            plan.features[index],
                            style: TextStyle(
                                color: textColor.withValues(alpha: 0.7),
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: isActive ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive
                    ? Colors.grey.withValues(alpha: 0.2)
                    : (isPremium
                        ? const Color(0xFF6366F1)
                        : textColor.withValues(alpha: 0.1)),
                foregroundColor:
                    isActive ? textColor.withValues(alpha: 0.3) : Colors.white,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r)),
                elevation: (isPremium && !isActive) ? 8 : 0,
                shadowColor: isPremium
                    ? const Color(0xFF6366F1).withValues(alpha: 0.4)
                    : Colors.transparent,
              ),
              child: Text(
                isActive
                    ? 'Active Plan'
                    : (isPremium ? 'Upgrade Now' : 'Current Plan'),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
