import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileStore {
  static final ProfileStore _instance = ProfileStore._internal();
  factory ProfileStore() => _instance;
  ProfileStore._internal();

  UserProfile profile = UserProfile();

  Future<void> load() async {
    final pref = await SharedPreferences.getInstance();
    final json = pref.getString('profile');
    if (json != null) {
      profile = UserProfile.fromJson(jsonDecode(json));
    }
  }

  Future<void> save() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('profile', jsonEncode(profile.toJson()));
  }
}