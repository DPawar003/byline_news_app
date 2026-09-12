class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String themePref;
  final String createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.themePref = 'system',
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      themePref: json['themePref'] as String? ?? 'system',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'themePref': themePref,
      'createdAt': createdAt,
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? themePref,
    String? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      themePref: themePref ?? this.themePref,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
