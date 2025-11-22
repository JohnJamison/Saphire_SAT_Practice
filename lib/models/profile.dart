class Profile {
  String username;
  String displayName;
  String password;
  String profilePhoto; // asset path or URL
  String country;
  String state;
  String city;
  String emailAddress;
  int phoneNumber;
  String userId;
  List<String> friends;   // list of user IDs this user is friends with
  List<int> questionHistory;

  // Constructor
  Profile(
    this.username,
    this.displayName, 
    this.password,
    this.profilePhoto,
    this.country,
    this.state,
    this.city,
    this.emailAddress,
    this.phoneNumber,
    this.userId,
    this.friends,  // list of user IDs this user is friends with
    this.questionHistory
  );

  // Getters
  String get userName {
    return username;
  }

  String get display_name {
    return displayName;
  }

  String get passWord {
    return password;
  }

  String get userState {
    return state;
  }

  String get userCity {
    return city;
  }

  String get userCountry {
    return country;
  }

  String get email {
    return emailAddress;
  }

  int get phone_number {
    return phoneNumber;
  }

  String get user_id {
    return userId;
  }

  List<String> get friends_ids {
    return friends;
  }

  List<int> get question_history {
    return questionHistory;
  }

  Map<String, dynamic> toMap() {
    return {
      "username": username,
      "displayName": displayName,
      "password": password, 
      "profilePhoto": profilePhoto,
      "country": country,
      "state": state,
      "city": city,
      "emailAddress": emailAddress,
      "phoneNumber": phoneNumber,
      "userId": userId,
      "friends": friends,
      "questionHistory": questionHistory,
    };
  }

}