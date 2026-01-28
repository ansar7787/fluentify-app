import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

part 'network_event.dart';
part 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker =
      InternetConnectionChecker();
  StreamSubscription? _subscription;

  NetworkBloc() : super(NetworkInitial()) {
    on<NetworkObserve>(_onObserve);
    on<NetworkNotify>(_onNotify);
  }

  void _onObserve(NetworkObserve event, Emitter<NetworkState> emit) {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      // connectivity_plus 6.0 returns List<ConnectivityResult>
      // but strictly checking internet needs real ping
      bool hasConnection = await _internetChecker.hasConnection;
      if (hasConnection) {
        add(const NetworkNotify(isConnected: true));
      } else {
        add(const NetworkNotify(isConnected: false));
      }
    });
  }

  void _onNotify(NetworkNotify event, Emitter<NetworkState> emit) {
    if (event.isConnected) {
      emit(NetworkSuccess());
    } else {
      emit(NetworkFailure());
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
