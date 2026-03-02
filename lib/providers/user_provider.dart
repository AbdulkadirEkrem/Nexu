import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Router kontrolü için gerekli
  bool get isAuthenticated => _auth.currentUser != null;

  /// LOGIN (Giriş Yapma)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = await _firestoreService.getUser(userCredential.user!.uid);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 👇 EKSİK OLAN VE HATAYI ÇÖZECEK FONKSİYON BU:
  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Firebase Auth ile kayıt ol
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Yeni kullanıcı modeli oluştur
      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        email: email.trim(),
        name: name.trim(),
        department: 'General', // Varsayılan
        position: 'Employee',  // Varsayılan
      );

      // 3. Firestore'a kaydet
      // DİKKAT: FirestoreService içinde createUser fonksiyonu olduğundan emin olacağız
      await _firestoreService.createUser(newUser);

      // 4. Local veriyi güncelle
      _currentUser = newUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Auth Durumunu Kontrol Et
  Future<void> checkAuthStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      _isLoading = true;
      notifyListeners(); // Yükleniyor durumunu bildir
      try {
        _currentUser = await _firestoreService.getUser(user.uid);
      } catch (e) {
        print("Error fetching user data: $e");
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user data from Firestore
  Future<void> refreshUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        _currentUser = await _firestoreService.getUser(user.uid);
        _errorMessage = null;
        notifyListeners();
      } catch (e) {
        _errorMessage = 'Failed to refresh user data: ${e.toString()}';
        notifyListeners();
      }
    }
  }
}