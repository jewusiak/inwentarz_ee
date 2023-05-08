class UserProfile {
  late int id;
  String? displayName;
  late String email;
  String? role;
  bool? isAccountEnabled;

  UserProfile(
      {required this.id,
      this.displayName,
      required this.email,
      this.role,
      this.isAccountEnabled});

  UserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    displayName = json['displayName'];
    email = json['email'];
    role = json['role'];
    isAccountEnabled = json['isAccountEnabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['displayName'] = this.displayName;
    data['email'] = this.email;
    data['role'] = this.role;
    data['isAccountEnabled'] = this.isAccountEnabled;
    return data;
  }
}
