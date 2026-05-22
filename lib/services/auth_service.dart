import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// AuthService is a class that handles ALL authentication tasks.
// Think of it as a "helper" that talks to Firebase on your behalf.
// Your screens just call these simple functions — they don't need
// to know HOW Firebase works, just WHAT result they get back.

class AuthService {
  // FirebaseAuth handles login, signup, logout
  // We use a single instance (_auth) throughout the app
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FirebaseFirestore handles storing/reading data (like a database)
  // We use a single instance (_firestore) throughout the app
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Get Current User ───────────────────────────────────────────────
  // Returns the currently logged-in user.
  // Returns null if no one is logged in.
  // Like asking "who is currently using the app right now?"
  User? get currentUser => _auth.currentUser;

  // ── Auth State Stream ──────────────────────────────────────────────
  // A stream that AUTOMATICALLY tells you when login state changes.
  // Like a security guard who calls you whenever someone
  // enters or leaves the building.
  // You will use this in main.dart later to decide which
  // screen to show (Login or Home).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ══════════════════════════════════════════════════════════════════
  // SIGNUP METHOD
  // ══════════════════════════════════════════════════════════════════
  // This function does 3 things:
  //   1. Creates a new user account in Firebase Authentication
  //   2. Saves user details in Firestore "users" collection
  //   3. Returns a success or error message

  Future<String?> signUp({
    required String name,       // user's full name
    required String email,      // user's email
    required String password,   // user's password
    required String role,       // 'buyer' or 'seller'
  }) async {
    // try/catch means:
    // "Try to do this. If anything goes wrong, catch the error
    //  and handle it gracefully instead of crashing the app."
    try {
      // STEP 1: Create user account in Firebase Authentication
      // This creates the login credentials (email + password)
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),      // .trim() removes accidental spaces
        password: password.trim(),
      );

      // STEP 2: Get the unique ID Firebase gave this new user
      // Every user in Firebase gets a unique ID automatically
      // Like a unique membership number
      String uid = userCredential.user!.uid;

      // STEP 3: Save extra user details in Firestore database
      // Firebase Authentication only stores email + password.
      // For name, role etc. we use Firestore.
      // This creates a document inside "users" collection
      // with the user's uid as the document ID.
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role,                         // 'buyer' or 'seller'
        'createdAt': FieldValue.serverTimestamp(), // current server time
      });

      // STEP 4: Update the display name in Firebase Auth too
      await userCredential.user!.updateDisplayName(name.trim());

      // If everything worked, return a success message
      return null;

    } on FirebaseAuthException catch (e) {
      // FirebaseAuthException gives us a specific error code
      // We convert that code into a human-friendly message
      return _handleAuthError(e.code);

    } catch (e) {
      // This catches any OTHER unexpected errors
      return 'Something went wrong. Please try again.';
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // LOGIN METHOD
  // ══════════════════════════════════════════════════════════════════
  // Takes email and password, tries to log the user in.
  // Returns 'success' if it worked, or an error message if not.

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // signInWithEmailAndPassword checks the email + password
      // against Firebase Authentication records
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Login worked!
      return null;

    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e.code);

    } catch (e) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // LOGOUT METHOD
  // ══════════════════════════════════════════════════════════════════
  // Signs out the current user.
  // After this, currentUser will be null.

  Future<String?> logout() async {
    try {
      await _auth.signOut();
      return null;

    } catch (e) {
      return 'Failed to logout. Please try again.';
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // GET USER DATA METHOD
  // ══════════════════════════════════════════════════════════════════
  // Fetches the logged-in user's details from Firestore.
  // Returns a Map (like a dictionary) with name, email, role etc.
  // Returns null if something goes wrong.

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      // Get the current user's uid
      String? uid = currentUser?.uid;

      // If no one is logged in, return null
      if (uid == null) return null;

      // Fetch the document from Firestore "users" collection
      // .get() fetches the data once (not a live stream)
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();

      // .data() returns the fields as a Map
      // Example: {'name': 'John', 'email': 'john@gmail.com', 'role': 'buyer'}
      return doc.data() as Map<String, dynamic>?;

    } catch (e) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // ERROR HANDLER (private helper function)
  // ══════════════════════════════════════════════════════════════════
  // Firebase gives error codes like 'user-not-found', 'wrong-password'
  // This function converts those technical codes into
  // simple messages your users can understand.
  // The underscore (_) before the name means it's PRIVATE —
  // only usable inside this class, not from outside.

  String _handleAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}