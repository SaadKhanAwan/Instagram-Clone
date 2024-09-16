import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram_clone/models/activityfeed.dart';
import 'package:instagram_clone/models/addpost_model.dart';
import 'package:instagram_clone/models/comments.dart';
import 'package:instagram_clone/models/user_model.dart';
import 'package:instagram_clone/viewmodel/services/notification_servies.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseNotification _firebaseNotification = FirebaseNotification();

  Future<String?> uploadImage(File imageFile, {required chidlName}) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = _storage.ref().child('$chidlName/$fileName');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log("Error uploading image: $e");
      return null;
    }
  }

  Future signUp({
    required String email,
    required String password,
    required String name,
    required File image,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user?.uid != null) {
        String? imageUrl = await uploadImage(image, chidlName: "user_images");
        UserData userData = UserData(
            bio: "hey!I am new to Instagram.",
            email: email,
            followers: [],
            following: [],
            id: userCredential.user!.uid,
            name: name,
            favorites: [],
            image: imageUrl ?? "",
            posts: []);
        _firestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(userData.toJson());
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuthException: ${e.message}");
      return null;
    } catch (e) {
      log("error in catch$e");
    }
  }

  Future signIn({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firebaseNotification.updateFcmToken();

  
    FirebaseNotification().listenForNotifications();
  
      return userCredential;
    } on FirebaseAuthException catch (e) {
      log("FirebaseAuthException: ${e.message}");
      return null;
    } catch (e) {
      log("error in catch$e");
    }
  }

  Future uploadPost({
    required String content,
    required File imageUrl,
  }) async {
    try {
      String? image = await uploadImage(imageUrl,
          chidlName: "post_images/${_auth.currentUser!.uid}");
      Post newPost = Post(
        postId: '',
        userId: _auth.currentUser!.uid,
        content: content,
        imageUrl: image,
        timestamp: DateTime.now(),
        likesCount: [],
        commentsCount: [],
      );
      DocumentReference docRef =
          await _firestore.collection('posts').add(newPost.toMap());
      await docRef.update({'postId': docRef.id});
      return "Sucussfull";
    } catch (e) {
      log("error:$e ");
      return null;
    }
  }

  // Method to fetch initial posts and paginate
  Future<List<Map<String, dynamic>>> fetchPostsWithUserData({
    int limit = 8,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(limit); // Limit applied here

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Fetch the posts
      QuerySnapshot postSnapshot = await query.get();

      if (postSnapshot.docs.isEmpty) {
        log("No posts found");
        return [];
      }

      List<Map<String, dynamic>> postsWithUserData = [];

      for (var postDoc in postSnapshot.docs) {
        var postData = postDoc.data() as Map<String, dynamic>;
        var userSnapshot =
            await _firestore.collection('users').doc(postData['userId']).get();

        if (userSnapshot.exists) {
          var userData = userSnapshot.data() as Map<String, dynamic>;
          postsWithUserData.add({
            'post': postData,
            'user': userData,
            'document': postDoc // Add document snapshot for pagination
          });
        }
      }

      log("Fetched ${postsWithUserData.length} posts");
      return postsWithUserData;
    } catch (e) {
      log("Error fetching posts with user data: $e");
      return [];
    }
  }

  Future<void> likePost(
    String postId, {
    required String username,
    required String userProfileImg,
    required String postImageUrl,
    required String recipientUserId,
  }) async {
    DocumentReference postRef = _firestore.collection("posts").doc(postId);

    await postRef.update({
      'likes': FieldValue.arrayUnion([_auth.currentUser!.uid])
    });

    if (recipientUserId != _auth.currentUser!.uid) {
      await addNotification(
          postId: postId,
          postImageUrl: postImageUrl,
          recipientUserId: recipientUserId,
          type: "like",
          userProfileImg: userProfileImg,
          username: username,
          commentId: "",
          comment: "");
    }
  }

  Future<void> dislikePost(String postId, {required recipientUserId}) async {
    DocumentReference postRef = _firestore.collection("posts").doc(postId);

    await postRef.update({
      'likes': FieldValue.arrayRemove([_auth.currentUser!.uid])
    });

    if (recipientUserId != _auth.currentUser!.uid) {
      await deleteNotification(
        type: "like",
        recipientUserId: recipientUserId,
        postId: postId,
      );
    }
  }

  Future<bool> isPostLikedByUser(String postId) async {
    DocumentSnapshot postSnapshot =
        await _firestore.collection("posts").doc(postId).get();
    List<dynamic> likes =
        (postSnapshot.data() as Map<String, dynamic>)['likes'] ?? [];
    return likes.contains(_auth.currentUser!.uid);
  }

  Future<void> deletePost(String postId) async {
    try {
      // Fetch the post document
      DocumentReference postRef = _firestore.collection("posts").doc(postId);
      DocumentSnapshot postSnapshot = await postRef.get();

      if (postSnapshot.exists) {
        var postData = postSnapshot.data() as Map<String, dynamic>;

        // Delete the image from Firebase Storage
        String? imageUrl = postData['imageUrl'];
        if (imageUrl != null && imageUrl.isNotEmpty) {
          await _deleteImage(imageUrl);
        }

        QuerySnapshot commentsSnapshot =
            await postRef.collection('comments').get();
        for (DocumentSnapshot commentDoc in commentsSnapshot.docs) {
          await commentDoc.reference.delete();
        }
        // Delete the post document from Firestore
        await postRef.delete();

        log("Post $postId deleted successfully.");
      }
    } catch (e) {
      log("Error deleting post $postId: $e");
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
      log("Image deleted successfully: $imageUrl");
    } catch (e) {
      log("Error deleting image: $e");
    }
  }

  // Method to add a comment
  Future<void> addComment({
    required String postId,
    required String content,
    required String username,
    required String userProfileImg,
    required String postImageUrl,
    required String recipientUserId,
  }) async {
    try {
      Comment comment = Comment(
          userId: FirebaseAuth.instance.currentUser!.uid,
          content: content,
          timestamp: DateTime.now());
      DocumentReference commentRef = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add(comment.toJson());

      String commentId = commentRef.id;

      if (recipientUserId != FirebaseAuth.instance.currentUser!.uid) {
        await addNotification(
          postId: postId,
          comment: content,
          type: "comment",
          username: username,
          userProfileImg: userProfileImg,
          postImageUrl: postImageUrl,
          recipientUserId: recipientUserId,
          commentId: commentId,
        );
      }
    } catch (e) {
      log("Error adding comment: $e");
    }
  }

  Stream<List<Comment>> fetchComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((QuerySnapshot querySnapshot) async {
      List<Comment> comments = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;
        String userId = commentData['userId'];

        // Fetch user details from the 'users' collection
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        comments.add(Comment(
          id: doc.id,
          userId: userId,
          content: commentData['content'],
          timestamp: (commentData['timestamp'] as Timestamp).toDate(),
          username: userData['name'] ?? 'Unknown User',
          profilePicture: userData['image'] ?? '',
        ));
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(doc.id)
            .update({"id": doc.id});
      }
      return comments;
    });
  }

  Future<void> deleteComment(String postId, String commentId,
      {required recipientUserId}) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      if (recipientUserId != FirebaseAuth.instance.currentUser!.uid) {
        await deleteNotification(
          type: "comment",
          recipientUserId: recipientUserId,
          postId: postId,
          commentId: commentId,
        );
      }
    } catch (e) {
      log("Error deleting comment: $e");
    }
  }

  Future<QuerySnapshot> fetchRandomImages({
    int limit = 12,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot;
    } catch (e) {
      log("Error fetching images: $e");
      rethrow; // Throw the error to be handled by the caller
    }
  }

  Future<List<UserData>> searchUsers(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      List<UserData> users = snapshot.docs.map((doc) {
        return UserData.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return users;
    } catch (e) {
      log("Error searching users: $e");
      return [];
    }
  }

  Future<UserData?> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!userSnapshot.exists) {
        log("User not found");
        return null;
      }

      UserData userData =
          UserData.fromJson(userSnapshot.data() as Map<String, dynamic>);
      return userData;
    } catch (e) {
      log("Error fetching user data: $e");
      return null;
    }
  }

  Future<List<Post>> fetchUserPosts(String userId) async {
    try {
      QuerySnapshot postSnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();

      List<Post> userPosts = postSnapshot.docs.map((doc) {
        return Post.fromDocumentSnapshot(doc.data() as Map<String, dynamic>);
      }).toList();

      // Sort posts by timestamp locally (if necessary)
      userPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return userPosts;
    } catch (e) {
      log("Error fetching user posts: $e");
      return [];
    }
  }

  Future updateProfile({username, userbio, imageUrl}) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': username,
      'bio': userbio,
      'image': imageUrl,
    });
  }

  Future signOut() async {
    await _auth.signOut();
  }

  // Follow a user
  Future<void> followUser(String targetUserId) async {
    try {
      String currentUserId = _auth.currentUser!.uid;

      // Add the target user's ID to the current user's "following" list
      await _firestore.collection('users').doc(currentUserId).update({
        'following': FieldValue.arrayUnion([targetUserId])
      });

      // Add the current user's ID to the target user's "followers" list
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayUnion([currentUserId])
      });

      DocumentSnapshot currentUserDoc =
          await _firestore.collection('users').doc(currentUserId).get();
      Map<String, dynamic> currentUserData =
          currentUserDoc.data() as Map<String, dynamic>;

      // Send follow notification
      await addNotification(
        username: currentUserData['name'],
        postId: '',
        userProfileImg: currentUserData['image'],
        postImageUrl: '',
        recipientUserId: targetUserId,
        type: "follow",
        commentId: "",
        comment: "",
      );

      log("Followed user: $targetUserId");
    } catch (e) {
      log("Error following user: $e");
    }
  }

  // Unfollow a user
  Future<void> unfollowUser(String targetUserId) async {
    try {
      String currentUserId = _auth.currentUser!.uid;

      // Remove the target user's ID from the current user's "following" list
      await _firestore.collection('users').doc(currentUserId).update({
        'following': FieldValue.arrayRemove([targetUserId])
      });

      // Remove the current user's ID from the target user's "followers" list
      await _firestore.collection('users').doc(targetUserId).update({
        'followers': FieldValue.arrayRemove([currentUserId])
      });

      // Delete follow notification
      await deleteNotification(
        type: "follow",
        recipientUserId: targetUserId,
        postId: '',
      );

      log("Unfollowed user: $targetUserId");
    } catch (e) {
      log("Error unfollowing user: $e");
    }
  }

  Stream<bool> isFollowingUserStream(String targetUserId) {
    String currentUserId = _auth.currentUser!.uid;

    return _firestore.collection('users').doc(currentUserId).snapshots().map(
      (snapshot) {
        List<dynamic> followingList = snapshot.data()?['following'] ?? [];
        return followingList.contains(targetUserId);
      },
    );
  }

  Future<void> addPostToFavorites({String? postId}) async {
    String currentUserId = _auth.currentUser!.uid;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'favorites': FieldValue.arrayUnion([postId])
      });
    } catch (e) {
      log("Error adding post to favorites: $e");
    }
  }

  Future<void> removePostFromFavorites({String? postId}) async {
    String currentUserId = _auth.currentUser!.uid;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'favorites': FieldValue.arrayRemove([postId])
      });
      log("Post $postId removed from favorites.");
    } catch (e) {
      log("Error removing post from favorites: $e");
    }
  }

  Future<bool> isPostFavorited(String postId) async {
    String currentUserId = _auth.currentUser!.uid;

    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(currentUserId).get();

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      List<dynamic> favorites = userData?['favorites'] ?? [];

      return favorites.contains(postId);
    } catch (e) {
      log("Error checking if post is favorited: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchFavoritePosts() async {
    String currentUserId = _auth.currentUser!.uid;

    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(currentUserId).get();

      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;

      List<dynamic> favoritePostIds = userData?['favorites'] ?? [];
      if (favoritePostIds.isEmpty) {
        return [];
      }
      QuerySnapshot postSnapshot = await _firestore
          .collection('posts')
          .where(FieldPath.documentId, whereIn: favoritePostIds)
          .get();
      List<Map<String, dynamic>> favoritePosts = [];

      for (var doc in postSnapshot.docs) {
        Map<String, dynamic> postData =
            Map<String, dynamic>.from(doc.data() as Map);
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(postData['userId']).get();

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        favoritePosts.add({
          'post': postData,
          'user': userData,
        });
      }

      return favoritePosts;
    } catch (e) {
      log("Error fetching favorite posts: $e");
      return [];
    }
  }

  Future<void> addNotification(
      {required String username,
      required String postId,
      required String userProfileImg,
      required String postImageUrl,
      required String recipientUserId,
      required String type,
      required String commentId,
      required String comment}) async {
    try {
      ActivityFeedItem feedItem = ActivityFeedItem(
        userId: _auth.currentUser!.uid,
        username: username,
        userProfileImg: userProfileImg,
        postImageUrl: postImageUrl,
        type: type,
        postId: postId,
        comment: comment,
        commentId: commentId,
        timestamp: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(recipientUserId)
          .collection('userNotifications')
          .doc()
          .set(feedItem.toJson());
      log('Notification added successfully');
    } catch (e) {
      log('Error adding notification: $e');
    }
  }

  Future<void> deleteNotification({
    required String type,
    required String recipientUserId,
    required String postId,
    String? commentId,
  }) async {
    try {
      // Query the notifications collection for the matching notification
      QuerySnapshot notificationsSnapshot = await _firestore
          .collection('notifications')
          .doc(recipientUserId)
          .collection('userNotifications')
          .where('type', isEqualTo: type)
          .where('postId', isEqualTo: postId) // Or postId field if you store it
          .get();

      if (commentId != null) {
        notificationsSnapshot = await _firestore
            .collection('notifications')
            .doc(recipientUserId)
            .collection('userNotifications')
            .where('type', isEqualTo: type)
            .where('commentId', isEqualTo: commentId)
            .get();
      }

      for (var doc in notificationsSnapshot.docs) {
        // Delete each matching notification
        await doc.reference.delete();
      }

      log('Notification deleted successfully');
    } catch (e) {
      log('Error deleting notification: $e');
    }
  }

  Stream<List<ActivityFeedItem>> fetchActivityFeed() {
    try {
      String currentUserId = _auth.currentUser!.uid;
      return FirebaseFirestore.instance
          .collection('notifications')
          .doc(currentUserId)
          .collection('userNotifications')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return ActivityFeedItem.fromDocument(
              doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      log("error is $e");
      return const Stream.empty();
    }
  }
}
