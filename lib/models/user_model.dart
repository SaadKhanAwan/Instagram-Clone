class UserData {
  String id;
  String name;
  String email;
  String bio;
  String image;
  List followers;
  List following;
  List posts;
  List  favorites;

  UserData({
    required this.id,
    required this.favorites,
    required this.name,
    required this.image,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
    required this.posts,
  });

  // Factory method to create a UserData instance from a JSON map
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      favorites: List.from(json['favorites'] ??[]) ,
      id: json['id'],
      image: json['image'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      followers: List.from(json['followers']),
      following: List.from(json['following']),
      posts: List.from(json['posts']),
    );
  }

  // Method to convert a UserData instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'favorites':favorites,
      'name': name,
      'email': email,
      'image': image,
      'bio': bio,
      'followers': followers,
      'following': following,
      'posts': posts,
    };
  }
}
