import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/viewmodel/controller/profile/profile_controller.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final mheight = MediaQuery.of(context).size.height;
    final mwidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (_) => ProfileController(userID: widget.userId),
      builder: (context, index) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Profile Screen'),
              actions: [
                TextButton.icon(
                  onPressed: () async {
                    final provider =
                        Provider.of<ProfileController>(context, listen: false);
                    _showLogoutSheet(context, provider);
                  },
                  icon: const Icon(
                    Icons.logout_sharp,
                    color: Colors.red,
                  ),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            ),
            body: Consumer<ProfileController>(
              builder: (context, provider, child) {
                return provider.state == ViewState.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: Colors.blue,
                      ))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    height: mheight * .13,
                                    width: mwidth * .25,
                                    fit: BoxFit.cover,
                                    imageUrl: provider.userData?.image ?? '',
                                    errorWidget: (context, url, error) =>
                                        const Icon(CupertinoIcons.person),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      provider.userPosts?.length.toString() ??
                                          '0',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text("Posts"),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      provider.followerCount
                                          .toString(), // Use the follower count from state
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text("Followers"),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      provider.userData?.following.length
                                              .toString() ??
                                          '0',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text("Following"),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SizedBox(),
                                widget.userId ==
                                        FirebaseAuth.instance.currentUser!.uid
                                    ? GestureDetector(
                                        onTap: () async {
                                          await provider.editprofie(
                                              context: context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            "Update",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : StreamBuilder<bool>(
                                        stream: provider.checkIsLogin(
                                            targetUserId: widget.userId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator(
                                              color: Colors.blue,
                                            );
                                          }

                                          bool isFollowing =
                                              snapshot.data ?? false;

                                          return GestureDetector(
                                            onTap: () async {
                                              provider.followUnfollow(
                                                  isFollowing: isFollowing,
                                                  userId: widget.userId);
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                isFollowing
                                                    ? "Unfollow"
                                                    : "Follow",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ],
                            ),
                            Text(
                              provider.userData?.name ?? '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              provider.userData?.email ?? '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              provider.userData?.bio ?? '',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const Divider(),
                            provider.userPosts == null ||
                                    provider.userPosts!.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No post found",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20),
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      physics: const ClampingScrollPhysics(),
                                      itemCount:
                                          (provider.userPosts!.length / 3)
                                              .ceil(),
                                      itemBuilder: (context, index) {
                                        int startIndex = index * 3;
                                        int endIndex = startIndex + 3;
                                        endIndex = endIndex <
                                                provider.userPosts!.length
                                            ? endIndex
                                            : provider.userPosts!.length;

                                        return Row(
                                          children: [
                                            for (int i = startIndex;
                                                i < endIndex;
                                                i++)
                                              Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: mwidth * .32),
                                                child: CachedNetworkImage(
                                                  height: mheight * .25,
                                                  width: mwidth * .30,
                                                  fit: BoxFit.cover,
                                                  imageUrl: provider
                                                          .userPosts![i]
                                                          .imageUrl ??
                                                      '',
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(CupertinoIcons
                                                          .person),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                          ],
                        ),
                      );
              },
            ));
      },
    );
  }

  Future<bool?> _showLogoutSheet(
      BuildContext context, ProfileController provider) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await provider.signOut(context: context);
              },
            ),
          ],
        );
      },
    );
  }
}
