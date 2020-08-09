import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'user.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Stream<FirebaseUser> user;
  PublishSubject<bool> loading = PublishSubject();

  AuthService._() {
    user = _auth.onAuthStateChanged;
  }
  static final AuthService instance = AuthService._();

  Future<FirebaseUser> googleSignIn() async {
    loading.add(true);
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    _updateUserData(user);
    loading.add(false);
    return user;
  }

  void _updateUserData(FirebaseUser user) {
    DocumentReference ref = _db.collection('users').document(user.uid);

    ref.setData({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
    }, merge: true);
  }

  void signInAnonymously() async {
    loading.add(true);
    AuthResult auth = await _auth.signInAnonymously();
    FirebaseUser user = auth.user;
    _updateUserData(user);
    loading.add(false);
  }

  void signOut() {
    _auth.signOut();
  }
}