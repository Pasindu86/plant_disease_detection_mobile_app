import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Google Sign-In (Firebase) ──────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out first to clear any cached authentication state
      await _googleSignIn.signOut();

      // Trigger the Google Sign-In flow (v7 API)
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      // Return null if user cancels the sign-in
      if (googleUser == null) {
        return null;
      }

      // Get the ID token from authentication
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      // Get an access token via authorization client
      String? accessToken;
      try {
        final clientAuth = await googleUser.authorizationClient.authorizeScopes(
          <String>['email', 'profile'],
        );
        accessToken = clientAuth.accessToken;
      } catch (_) {
        // Authorization may fail on some platforms; proceed with idToken only
      }

      // Create a Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      // Create user document in Firestore if doesn't exist
      if (userCredential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'uid': userCredential.user!.uid,
                'email': userCredential.user!.email ?? '',
                'name': userCredential.user!.displayName,
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              });
        }
      }

      return userCredential;
    } on GoogleSignInException catch (e) {
      // Handle specific Google Sign-In errors
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // User cancelled the sign-in
        return null;
      } else {
        // Configuration issue - likely SHA-1 fingerprint not set up
        throw Exception(
          'Google Sign-In configuration error. '
          'Please ensure SHA-1 fingerprint is added to Firebase Console.\n'
          'Error code: ${e.code}\n'
          'Details: ${e.toString()}',
        );
      }
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  // ─── Email Sign-Up (Firebase) ──────────────────────────────
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? name,
    String? phoneNumber,
  }) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      if (credential.user != null) {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'phoneNumber': phoneNumber,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw Exception('Email Sign-Up failed: $e');
    }
  }

  // ─── Email Sign-In (Firebase) ──────────────────────────────
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      
      // Create user document in Firestore if doesn't exist (consistency with Google Sign-In)
      if (credential.user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!userDoc.exists) {
          await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .set({
                'uid': credential.user!.uid,
                'email': credential.user!.email ?? email,
                'name': credential.user!.displayName,
                'createdAt': DateTime.now().toIso8601String(),
                'updatedAt': DateTime.now().toIso8601String(),
              });
        }
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw Exception('Email Sign-In failed: $e');
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ─── Auth State ────────────────────────────────────────────
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  User? get currentUser => _firebaseAuth.currentUser;

  // ─── Friendly error messages ───────────────────────────────
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
