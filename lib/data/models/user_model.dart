import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String bio;
  final String? profileImage;
  final String location;
  final String? website;
  final int followers;
  final int following;
  final int stories;
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.bio,
    this.profileImage,
    required this.location,
    this.website,
    required this.followers,
    required this.following,
    required this.stories,
    this.isVerified = false,
  });
}

class Story {
  final String id;
  final String title;
  final String description;
  final String image;
  final String author;
  final int likes;
  final int views;
  final DateTime publishedDate;
  final List<User> collaborators;
  final bool isDraft;

  Story({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.author,
    required this.likes,
    required this.views,
    required this.publishedDate,
    this.collaborators = const [],
    this.isDraft = false,
  });
}
