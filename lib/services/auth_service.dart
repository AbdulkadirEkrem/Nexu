import '../models/user_model.dart';

abstract class AuthService {
  Future<UserModel?> login(String email, String password);
  Future<UserModel?> signUp(String email, String password, String name);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  bool get isAuthenticated;
}

