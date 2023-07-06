import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';

typedef MembersMap = Map<String, Member>;

@JsonSerializable(anyMap: true, explicitToJson: true)
class Member extends ChangeNotifier {
  final String key;
  final String userId;
  final String name;
  final bool isAdmin;
  final bool isBread;
  final bool hasVotedForWord;
  final int points;

  Member(
      {required this.key,
      required this.userId,
      required this.isAdmin,
      required this.points,
      required this.hasVotedForWord,
      required this.name,
      required this.isBread});

  factory Member.firstFromJson(Map<dynamic, dynamic> json) =>
      Member.fromJson(json.values.first);

  factory Member.fromJson(Map<dynamic, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

@JsonSerializable(anyMap: true, explicitToJson: true)
@immutable
class UserIsBread {
  final bool value;

  const UserIsBread(this.value);

  factory UserIsBread.fromJson(Map<dynamic, dynamic> json) =>
      _$UserIsBreadFromJson(json);
}
