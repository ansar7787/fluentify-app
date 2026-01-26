import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  const RegisterRequested(this.email, this.password, this.fullName);

  @override
  List<Object> get props => [email, password, fullName];
}

class FirebaseLoginRequested extends AuthEvent {
  final String token;

  const FirebaseLoginRequested(this.token);

  @override
  List<Object> get props => [token];
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
  @override
  List<Object> get props => [email];
}

class GoogleLoginRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class AuthCheckStatus extends AuthEvent {}
