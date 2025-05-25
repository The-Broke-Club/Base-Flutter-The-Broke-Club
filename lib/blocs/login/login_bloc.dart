import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../../repositories/auth_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc(this.authRepository) : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        final success = await authRepository.login(event.email, event.password);
        if (success) {
          emit(LoginSuccess());
        } else {
          emit(LoginFailure('Credenciais inválidas.'));
        }
      } catch (e) {
        emit(LoginFailure(e.toString()));
      }
    });
  }
}
