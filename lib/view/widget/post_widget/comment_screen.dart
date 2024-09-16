import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/comments.dart';
import 'package:instagram_clone/viewmodel/controller/comments/comments_controller.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatefulWidget {
  final String psotID;
  final String? postImage;
  final String? userId;

  const CommentScreen({
    super.key,
    required this.psotID,
    this.postImage,
    this.userId,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  @override
  Widget build(BuildContext context) {

    final mheight = MediaQuery.of(context).size.height;
    final mwidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider(
      create: (_) => CommentsController(postID: widget.psotID),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios),
            ),
            centerTitle: true,
            title: const Text("Comment Screen"),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Column(
              children: [
                Consumer<CommentsController>(
                    builder: (context, provider, child) {
                  return provider.isposting
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: LinearProgressIndicator(
                            value: null,
                            color: Colors.blue,
                          ),
                        )
                      : const SizedBox.shrink();
                }),
                Consumer<CommentsController>(
                    builder: (context, provider, child) {
                  return Expanded(
                      child: StreamBuilder<List<Comment>>(
                    stream: provider.commentsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                          color: Colors.blue,
                        ));
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text(
                          'No comments yet',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ));
                      }

                      final comments = snapshot.data!;
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(mheight * .1),
                              child: CachedNetworkImage(
                                height: mheight * .10,
                                width: mwidth * .14,
                                fit: BoxFit.cover,
                                imageUrl: comment.profilePicture!,
                                errorWidget: (context, url, error) =>
                                    const Icon(CupertinoIcons.person),
                              ),
                            ),
                            title: Text(
                              comment.username.toString(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.content,
                                  maxLines: null,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(provider.timeAgo(comment.timestamp)),
                              ],
                            ),
                            trailing: comment.userId ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      provider.deleteComment(
                                          postId: widget.psotID,
                                          commentId: comment.id,
                                          recipientUserId:  widget.userId!,
                                          context: context);
                                    },
                                  )
                                : SizedBox.fromSize(),
                          );
                        },
                      );
                    },
                  ));
                }),
                Consumer<CommentsController>(
                    builder: (context, provider, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: provider.commentController,
                          maxLines: null,
                          maxLength: null,
                          decoration: InputDecoration(
                            hintText: 'Write a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (!provider.isposting) {
                            FocusScope.of(context).unfocus();
                            await provider.addComment(
                              context: context,
                              postID: widget.psotID,
                              postImageUrl: widget.postImage!,
                              recipientUserId: widget.userId!,
                            );
                          }
                        },
                        icon: const Icon(Icons.send),
                        color: provider.isposting ? Colors.grey : Colors.blue,
                      ),
                    ],
                  );
                })
              ],
            ),
          ),
        );
      },
    );
  }
}
