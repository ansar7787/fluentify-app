import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String price;
  final int rawPrice; // For backend/Razorpay
  final String interval;
  final List<String> features;
  final bool isPopular;
  final int level; // For hierarchy awareness

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.rawPrice,
    required this.interval,
    required this.features,
    this.isPopular = false,
    required this.level,
  });

  @override
  List<Object?> get props =>
      [id, name, price, rawPrice, interval, features, isPopular, level];

  static const List<SubscriptionPlan> defaultPlans = [
    SubscriptionPlan(
      id: 'free',
      level: 0,
      name: 'Basic',
      price: 'Free',
      rawPrice: 0,
      interval: 'Forever',
      features: [
        '10 AI Missions / day',
        'Standard Pronunciation Check',
        'Public Leaderboard access',
      ],
    ),
    SubscriptionPlan(
      id: 'starter',
      level: 1,
      name: 'Starter',
      price: '₹49',
      rawPrice: 49,
      interval: 'Per Month',
      features: [
        '30 AI Missions / day',
        'Detailed Fluency Feedback',
        'No Banner Ads',
        'Exclusive "Learner" Badge',
      ],
    ),
    SubscriptionPlan(
      id: 'standard',
      level: 2,
      name: 'Standard',
      price: '₹129',
      rawPrice: 129,
      interval: 'Per Month',
      isPopular: true,
      features: [
        'Unlimited AI Missions',
        'Advanced GPT-4 Analysis',
        'Peer Speaking Rooms',
        'Monthly Progress Report',
        'Priority AI Processing',
      ],
    ),
    SubscriptionPlan(
      id: 'pro',
      level: 3,
      name: 'Pro',
      price: '₹249',
      rawPrice: 249,
      interval: 'Per Month',
      features: [
        'All Standard Features',
        '1-on-1 AI Mentor (Voice)',
        'Interview Preparation Kit',
        'Custom Learning Path',
        'Certificate of Completion',
      ],
    ),
    SubscriptionPlan(
      id: 'elite',
      level: 4,
      name: 'Elite',
      price: '₹499',
      rawPrice: 499,
      interval: 'Per Month',
      features: [
        'All Pro Features',
        'Live Group Classes (Weekly)',
        'Business English Mastery',
        'Personal Accent Training',
        'VIP Direct Support',
        'Lifetime Portfolio Host',
      ],
    ),
  ];
}
