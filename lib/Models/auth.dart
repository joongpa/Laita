import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User> user;
  PublishSubject<bool> loading = PublishSubject();

  AuthService._() {
    user = _auth.authStateChanges();
  }
  static final AuthService instance = AuthService._();

  Future<User> googleSignIn() async {
    loading.add(true);
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    _updateUserData(user);
    loading.add(false);
    return user;
  }

  void _updateUserData(User user) {
    DocumentReference ref = _db.collection('users').doc(user.uid);

    ref.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
    }, SetOptions(merge: true));
  }

  void signOut() {
    _auth.signOut();
  }
}