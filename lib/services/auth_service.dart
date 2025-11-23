import 'package:firebase_auth/firebase_auth.dart';
import 'package:pashu_swasthya/services/database_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  // Send OTP via Firebase
  Future<void> sendOtp(
    String mobileNumber, {
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91$mobileNumber', // Assuming India for now based on +91 prefix in UI
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _auth.signInWithCredential(credential);
          // You might want to trigger a callback here to auto-login the user
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<bool> verifyOtp(String enteredOtp) async {
    if (_verificationId == null) return false;

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: enteredOtp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user != null;
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }

  Future<void> loginUser(String mobileNumber, {String? userName, String? userPlace}) async {
    await DatabaseHelper().loginUser(
      mobileNumber,
      userName: userName,
      userPlace: userPlace,
    );
  }
  
  // Check if user is already signed in with Firebase
  User? get currentUser => _auth.currentUser;
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
