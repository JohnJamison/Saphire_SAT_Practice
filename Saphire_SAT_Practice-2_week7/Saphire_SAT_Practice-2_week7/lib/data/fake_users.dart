class UserProfile {
  final int id;
  final String name;
  final String avatar;
  UserProfile(this.id, this.name, this.avatar);
}

final List<UserProfile> allUsers = [
  UserProfile(1, "Alice Johnson", "👩🏻"),
  UserProfile(2, "Brian Kim", "🧑🏼"),
  UserProfile(3, "Catherine Lee", "👩🏽‍🦰"),
  UserProfile(4, "Daniel Park", "🧑🏻‍💼"),
  UserProfile(5, "Emily Stone", "👩🏼‍🎓"),
  UserProfile(6, "Frank White", "🧑🏻‍🔧"),
  UserProfile(7, "Grace Miller", "👩🏾‍🏫"),
];
