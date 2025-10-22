import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_email.dart';
import '../../domain/usecases/sign_in_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_email.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository repository,
    required SignInEmail signInEmail,
    required SignUpEmail signUpEmail,
    required SignInGoogle signInGoogle,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
  })  : _repository = repository,
        _signInEmail = signInEmail,
        _signUpEmail = signUpEmail,
        _signInGoogle = signInGoogle,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<_AuthUserUpdated>(_onUserUpdated);
  }

  final AuthRepository _repository;
  final SignInEmail _signInEmail;
  final SignUpEmail _signUpEmail;
  final SignInGoogle _signInGoogle;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;

  StreamSubscription<AuthUser?>? _userSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final Either<Failure, AuthUser?> result = await _getCurrentUser();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
      (user) {
        emit(state.copyWith(
          status: user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
          user: user,
        ));
      },
    );
    await _userSubscription?.cancel();
    _userSubscription = _repository.watchUser().listen((user) {
      add(_AuthUserUpdated(user));
    });
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signInEmail(event.params);
    _handleAuthResult(result, emit);
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signUpEmail(event.params);
    _handleAuthResult(result, emit);
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signInGoogle();
    _handleAuthResult(result, emit);
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _signOut();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(const AuthState(status: AuthStatus.unauthenticated)),
    );
  }

  void _onUserUpdated(
    _AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(
      status: event.user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
      user: event.user,
      errorMessage: null,
    ));
  }

  void _handleAuthResult(
    Either<Failure, AuthUser> result,
    Emitter<AuthState> emit,
  ) {
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      )),
    );
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}

class _AuthUserUpdated extends AuthEvent {
  _AuthUserUpdated(this.user);

  final AuthUser? user;
}
