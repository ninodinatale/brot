import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'member.g.dart';

typedef MembersMap = Map<String, Member>;
typedef UserIsBread = bool;

@JsonSerializable(anyMap: true, explicitToJson: true)
class Member extends ChangeNotifier {
  final String key;
  final String userId;
  final String name;
  final bool isAdmin;
  final bool isBread;
  final bool hasVotedForWord;

  Member(
      {required this.key,
      required this.userId,
      this.isAdmin = false,
      this.hasVotedForWord = false,
      required this.name,
      this.isBread = false});

  factory Member.firstFromJson(Map<dynamic, dynamic> json) =>
      Member.fromJson(json.values.first);

  factory Member.fromJson(Map<dynamic, dynamic> json) => _$MemberFromJson(json);

  Map<String, dynamic> toJson() => _$MemberToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
