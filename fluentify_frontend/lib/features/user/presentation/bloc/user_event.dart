import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class GetUserProfileEvent extends UserEvent {}

class UpdateUserProfileEvent extends UserEvent {
  final String? fullName;
  final String? avatarUrl;
  final int? gameLevel;

  const UpdateUserProfileEvent({this.fullName, this.avatarUrl, this.gameLevel});

  @override
  List<Object?> get props => [fullName, avatarUrl, gameLevel];
}
