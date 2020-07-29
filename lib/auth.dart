import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Stream<FirebaseUser> user;
  Stream<Map<String, dynamic>> profile;
  PublishSubject<bool> loading = PublishSubject();

  AuthService._() {
    user = _auth.onAuthStateChanged;
    profile = user.switchMap((FirebaseUser u) {
      if(u != null) {
        return _db.collection('users').document(u.uid).snapshots().map((snap) => snap.data);
      } else {
        return Stream.empty();
      }
    });
  }
  static final AuthService _authService = AuthService._();

  factory AuthService() {
    return _authService;
  }

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
    await _auth.signInAnonymously();
    loading.add(false);
  }

  void signOut() {
    _auth.signOut();
  }
}