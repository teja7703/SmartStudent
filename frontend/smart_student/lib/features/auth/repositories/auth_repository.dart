import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final StorageService _storageService;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required ApiClient apiClient,
    required StorageService storageService,
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _apiClient = apiClient,
        _storageService = storageService,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<UserModel?> getStoredUser() async {
    final data = await _storageService.getUser();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Sign in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _signInWithFirebaseCredential(credential);
  }

  /// Starts Firebase phone verification. Callbacks mirror the underlying
  /// Firebase API but [onAutoVerified] already performs the backend sign-in
  /// so the cubit only deals with [UserModel]s.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(UserModel user) onAutoVerified,
    required void Function(String message) onFailed,
    int? resendToken,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final user = await _signInWithFirebaseCredential(
            credential,
            phoneNumber: phoneNumber,
          );
          onAutoVerified(user);
        } catch (_) {
          // Auto-retrieval failed silently; user can still type the code.
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        onFailed(_phoneErrorMessage(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  /// Verifies the manually entered [smsCode] and signs the user in.
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _signInWithFirebaseCredential(credential, phoneNumber: phoneNumber);
  }

  Future<UserModel> _signInWithFirebaseCredential(
    AuthCredential credential, {
    String? phoneNumber,
  }) async {
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user!;

    final response = await _apiClient.post(
      '/api/auth/login',
      data: {
        'firebaseUid': user.uid,
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? phoneNumber ?? '',
        'name': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
      },
    );

    final userModel = UserModel.fromJson(response.data['data']);
    await _storageService.saveUser(userModel.toJson());
    return userModel;
  }

  String _phoneErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid phone number.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'quota-exceeded':
        return 'SMS limit reached. Please try again later.';
      default:
        return e.message ?? 'Phone verification failed. Please try again.';
    }
  }

  Future<UserModel> updateProfile({
    required String firebaseUid,
    required String name,
    required String photoUrl,
  }) async {
    final response = await _apiClient.put(
      '/api/auth/profile',
      data: {
        'firebaseUid': firebaseUid,
        'name': name,
        'photoUrl': photoUrl,
      },
    );

    final userModel = UserModel.fromJson(response.data['data']);
    await _storageService.saveUser(userModel.toJson());
    return userModel;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await _storageService.clearUser();
  }
}
