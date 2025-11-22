class Profile {
  String username;
  String displayName;
  String password;
  String state;
  String city;
  String country;
  String emailAddress;
  int phoneNumber;
  String userId;
  List<int> questionHistory;

  // Constructor
  Profile(
    this.username,
    this.displayName, 
    this.password,
    this.state,
    this.city,
    this.country,
    this.emailAddress,
    this.phoneNumber,
    this.userId,
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

  List<int> get question_history {
    return questionHistory;
  }
}