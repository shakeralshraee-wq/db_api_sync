class UserModel {
  int id;
  String username;
  String email;
  String firstName;
  String lastName;
  String gender;
  String image;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final idVal = json['id'] ?? json['userId'] ?? 0;
    final emailVal = (json['email'] ?? json['username'] ?? '').toString();
    final usernameVal =
        (json['username'] ?? emailVal.split('@').first).toString();
    return UserModel(
      id: idVal is int ? idVal : int.tryParse(idVal.toString()) ?? 0,
      username: usernameVal,
      email: emailVal,
      firstName: (json['firstName'] ?? json['first_name'] ?? '').toString(),
      lastName: (json['lastName'] ?? json['last_name'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      image: (json['image'] ?? json['avatar'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}
