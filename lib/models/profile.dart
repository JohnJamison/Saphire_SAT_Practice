class Profile {
  String username;
  String email_address;
  String password;
  int highest_reading_score = 0;
  int highest_writing_score = 0;
  int highest_math_score = 0;

  // Constructor
  Profile(this.username, this.email_address, this.password);

  // Getters
  String get profile_name {
    return username;
  }

  String get email {
    return email_address;
  }

  int get highest_score_reading {
    return highest_reading_score;
  }

  int get highest_score_writing {
    return highest_writing_score;
  }

  int get highest_score_math {
    return highest_math_score;
  }

}