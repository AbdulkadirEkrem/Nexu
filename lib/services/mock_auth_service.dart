import 'auth_service.dart';
import '../models/user_model.dart';

class MockAuthService implements AuthService {
  UserModel? _currentUser;

  @override
  Future<UserModel?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication: accept any email ending with @company.com and password "123456"
    if (email.endsWith('@company.com') && password == '123456') {
      // Extract name from email
      final name = email.split('@')[0];
      final capitalizedName = name[0].toUpperCase() + name.substring(1);

      _currentUser = UserModel(
        id: 'user_${email.hashCode}',
        email: email,
        name: capitalizedName,
        department: _getDepartmentFromEmail(email),
        position: 'Employee',
      );

      return _currentUser;
    }

    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentUser;
  }

  @override
  bool get isAuthenticated => _currentUser != null;

  String _getDepartmentFromEmail(String email) {
    // Simple mock logic to assign departments
    final hash = email.hashCode.abs();
    final departments = ['Engineering', 'Sales', 'Marketing', 'HR', 'Finance'];
    return departments[hash % departments.length];
  }
}

