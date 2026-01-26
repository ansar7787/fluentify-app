import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? profileImage;
  final int coins;
  final int streakCount;
  final String level;
  final int missionsCompleted;
  final String subscriptionPlan;
  final DateTime? subscriptionExpiry;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    this.profileImage,
    required this.coins,
    required this.streakCount,
    required this.level,
    this.missionsCompleted = 0,
    this.subscriptionPlan = 'free',
    this.subscriptionExpiry,
  });

  bool get isPremium => subscriptionPlan == 'premium';

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        profileImage,
        coins,
        streakCount,
        level,
        missionsCompleted,
        subscriptionPlan,
        subscriptionExpiry,
      ];
}
