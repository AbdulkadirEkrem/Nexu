import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'auth_service.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class FirebaseAuthService implements AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      // DİKKAT: @company.com kontrolü buradan KALDIRILDI.
      // Artık Firebase'in kabul ettiği her mail geçerlidir.

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        return await _getUserModelFromFirebaseUser(credential.user!);
      }

      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      // DİKKAT: @company.com kontrolü buradan da KALDIRILDI.

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // İsim bilgisini Firebase profiline de işleyelim
        await credential.user!.updateDisplayName(name.trim());

        // Create user document in Firestore using FirestoreService
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email.trim(),
          name: name.trim(),
          department: 'General', // Default department, can be updated later
          position: 'Employee',
        );

        // Save to Firestore using FirestoreService (includes companyDomain extraction)
        await _firestoreService.saveUser(userModel);

        return userModel;
      }

      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        return await _getUserModelFromFirebaseUser(firebaseUser);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> _getUserModelFromFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    try {
      // Use FirestoreService to get user data
      final userModel = await _firestoreService.getUser(firebaseUser.uid);

      if (userModel != null) {
        return userModel;
      }

      // If user document doesn't exist, create a basic one
      final newUserModel = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? _extractNameFromEmail(firebaseUser.email ?? ''),
        department: 'General',
        position: 'Employee',
      );

      // Save to Firestore using FirestoreService
      await _firestoreService.saveUser(newUserModel);

      return newUserModel;
    } catch (e) {
      // Fallback if Firestore fails
      return UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: _extractNameFromEmail(firebaseUser.email ?? ''),
        department: 'General',
        position: 'Employee',
      );
    }
  }

  String _extractNameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    final name = email.split('@')[0];
    if (name.isEmpty) return 'User';
    return name[0].toUpperCase() + name.substring(1);
  }


  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Wrong password');
      case 'email-already-in-use':
        return Exception('Email already in use');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'too-many-requests':
        return Exception('Too many requests. Please try again later');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}
