import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/view/screens/pages/profile_screen.dart';
import 'package:instagram_clone/view/widget/post_widget/comment_screen.dart';
import 'package:instagram_clone/viewmodel/controller/pages/home_controller.dart';
import 'package:provider/provider.dart';

class Postcard extends StatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, dynamic> user;
  const Postcard({super.key, required this.post, required this.user});

  @override
  State<Postcard> createState() => _PostcardState();
}

class _PostcardState extends State<Postcard>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  _init() async {
    final provider = Provider.of<HomeController>(context, listen: false);
    await provider.likeFunctionality(widget.post['postId']);
    provider.likeCountFunctionality(
        likes: widget.post['likes'].length, postId: widget.post['postId']);
    provider.checkIsFavourite(postId: widget.post['postId']);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final homeController = Provider.of<HomeController>(context, listen: false);
    final mheight = MediaQuery.of(context).size.height;
    final mwidth = MediaQuery.of(context).size.width;
    final bool isCurrentUser =
        widget.post['userId'] == FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(mheight * .1),
              child: GestureDetector(
                onTap: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => UserProfileScreen(
                              userId: widget.post['userId'])));
                },
                child: CachedNetworkImage(
                  height: mheight * .10,
                  width: mwidth * .14,
                  fit: BoxFit.cover,
                  imageUrl: widget.user['image'] ?? '',
                  errorWidget: (context, url, error) =>
                      const Icon(CupertinoIcons.person),
                ),
              ),
            ),
            title: Text(widget.user['name'] ?? ''),
            trailing: isCurrentUser
                ? InkWell(
                    onTap: () async {
                      bool? result = await _showDeleteDialog(
                        context,
                      );
                      if (result == true) {
                        // ignore: use_build_context_synchronously
                        await homeController.deletePost(widget.post['postId'],
                            context: context);
                      }
                    },
                    child: const Icon(
                      Icons.more_vert,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        CachedNetworkImage(
          height: MediaQuery.of(context).size.height * .35,
          width: double.infinity,
          fit: BoxFit.cover,
          imageUrl: widget.post["imageUrl"],
          errorWidget: (context, url, error) =>
              const Icon(CupertinoIcons.person),
        ),
        Padding(
            padding: EdgeInsets.only(
              top: mheight * .01,
              left: mwidth * .01,
            ),
            child: Consumer<HomeController>(
              builder: (context, postController, chidl) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => homeController.toggleLikePost(
                            widget.post['postId'] ?? "",
                            postImageUrl: widget.post["imageUrl"] ?? "",
                            recipientUserId: widget.post['userId'] ?? "",
                          ),
                          child: homeController
                                      .isLikedMap[widget.post["postId"]] ??
                                  false
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : const Icon(
                                  Icons.favorite_border,
                                ),
                        ),
                        SizedBox(
                          width: mwidth * .05,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CommentScreen(
                                          psotID: widget.post['postId'],
                                          postImage: widget.post["imageUrl"],
                                          userId: widget.post['userId'],
                                        )));
                          },
                          child: const Icon(
                            Icons.comment_outlined,
                            // color: Colors.blue,
                            size: 39,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Consumer<HomeController>(
                        builder: (context, postController, child) {
                          return IconButton(
                            icon: postController.isFavoritedMap[
                                        widget.post['postId']] ??
                                    false
                                ? const Icon(Icons.bookmark,
                                    size: 30, color: Colors.white)
                                : const Icon(Icons.bookmark_outline, size: 30),
                            onPressed: () async {
                              await postController
                                  .toggleFavorite(widget.post['postId']);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            )),
        Padding(
          padding: EdgeInsets.only(
            top: mheight * .01,
            left: mwidth * .03,
          ),
          child: Row(
            children: [
              Consumer<HomeController>(
                  builder: (context, postController, child) {
                int likeCount =
                    postController.likeCountMap[widget.post['postId']] ?? 0;
                return Text(
                  "$likeCount",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                );
              }),
              SizedBox(
                width: mwidth * .05,
              ),
              const Text(
                "Likes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: mheight * .01,
            left: mwidth * .03,
            right: mwidth * .03,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.post['content'] == "null"
                      ? ""
                      : widget.post['content'],
                  maxLines: null,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: mwidth * .05,
              ),
              Flexible(
                  child: Text(
                homeController.timeAgo(widget.post['timestamp'].toDate()),
                maxLines: null,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              )),
            ],
          ),
        ),
        const Divider(),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  Future<bool?> _showDeleteDialog(
    BuildContext context,
  ) {
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
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
