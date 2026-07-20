class AppUser {
  AppUser({
    required this.id,
    required this.fullname,
    required this.email,
    required this.phone,
    required this.balance,
    required this.role,
    this.photoUrl,
  });

  final int id;
  final String fullname;
  final String email;
  final String phone;
  final double balance;
  final String role;
  final String? photoUrl;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        fullname: json['fullname'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        balance: (json['balance'] as num).toDouble(),
        role: json['role'] as String,
        photoUrl: json['photo_url'] as String?,
      );

  AppUser copyWith({String? fullname, String? phone, double? balance, String? photoUrl}) => AppUser(
        id: id,
        fullname: fullname ?? this.fullname,
        email: email,
        phone: phone ?? this.phone,
        balance: balance ?? this.balance,
        role: role,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}
