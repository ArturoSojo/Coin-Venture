import 'dart:convert';

import 'package:equatable/equatable.dart';

class SessionToken extends Equatable {
  const SessionToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiry;

  bool get isExpired => DateTime.now().isAfter(expiry);

  SessionToken copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiry,
  }) {
    return SessionToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiry: expiry ?? this.expiry,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiry': expiry.toIso8601String(),
      };

  String toJson() => jsonEncode(toMap());

  factory SessionToken.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return SessionToken(
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
      expiry: DateTime.parse(map['expiry'] as String),
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiry];
}
