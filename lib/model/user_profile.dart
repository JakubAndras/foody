enum ProfileSex { male, female, other }

extension ProfileSexX on ProfileSex {
  String get code {
    switch (this) {
      case ProfileSex.male:
        return 'male';
      case ProfileSex.female:
        return 'female';
      case ProfileSex.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case ProfileSex.male:
        return 'Male';
      case ProfileSex.female:
        return 'Female';
      case ProfileSex.other:
        return 'Other';
    }
  }
}

ProfileSex? profileSexFromCode(String? code) {
  switch (code) {
    case 'male':
      return ProfileSex.male;
    case 'female':
      return ProfileSex.female;
    case 'other':
      return ProfileSex.other;
  }
  return null;
}

enum ProfileGoal { lose, maintain, gain }

extension ProfileGoalX on ProfileGoal {
  String get code {
    switch (this) {
      case ProfileGoal.lose:
        return 'lose';
      case ProfileGoal.maintain:
        return 'maintain';
      case ProfileGoal.gain:
        return 'gain';
    }
  }
}

ProfileGoal? profileGoalFromCode(String? code) {
  switch (code) {
    case 'lose':
      return ProfileGoal.lose;
    case 'maintain':
      return ProfileGoal.maintain;
    case 'gain':
      return ProfileGoal.gain;
  }
  return null;
}
