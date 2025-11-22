import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile.dart';


// Check this one out and coordinate with Dawson
class ProfileService {
  static Future<void> saveProfile(Profile profile) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(profile.userId)
        .set(profile.toMap());
  }
}
