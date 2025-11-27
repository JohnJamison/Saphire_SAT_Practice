import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a new user document
  Future<void> addUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data);
  }

  // Get a single user
  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // Stream users (for real-time updates)
  Stream<QuerySnapshot> streamUsers() {
    return _db.collection('users').snapshots();
  }
}
