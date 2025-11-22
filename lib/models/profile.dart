class Profile {
  String username;
  String displayName;
  String password;
  String state;
  String city;
  String country;
  String emailAddress;
  String userId;

  // Constructor
  Profile(
    this.username,
    this.displayName, 
    this.password,
    this.state,
    this.city,
    this.country,
    this.emailAddress,
    this.userId
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

  String get user_id {
    return userId;
  }


}