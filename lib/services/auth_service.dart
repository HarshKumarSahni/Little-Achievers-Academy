import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lla_sample/models/userprofile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Auth State Stream
  Stream<User?> get user => _auth.authStateChanges();

  // Current User
  User? get currentUser => _auth.currentUser;

  // Sign in with Google
  // Returns the User object but DOES NOT create the profile yet.
  // The UI will check if the profile exists and route to Registration if needed.
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Cancelled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;
      
      return user;
    } catch (e) {
      print("Google Sign In Error: $e");
      return null;
    }
  }

  // Sign in Anonymously (Guest)
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print("Anon Sign In Error: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Check if User Profile Exists and is Complete
  Future<bool> isUserProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _db.collection('students').doc(user.uid).get();
    if (!doc.exists) return false;

    final data = doc.data();
    if (data == null) return false;
    
    // Check for the flag we added
    return data['isProfileComplete'] == true;
  }

  // Save/Update User Profile (called from Registration Page)
  Future<void> completeRegistration(UserProfile profile) async {
    await _db.collection('students').doc(profile.id).set(profile.toJson());
  }

  // Fetch Full Profile
  Stream<UserProfile?> getUserProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _db.collection('students').doc(user.uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
