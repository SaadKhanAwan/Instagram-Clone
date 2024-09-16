import 'package:flutter/material.dart';
import 'package:instagram_clone/data/helper/baseviewmodel/baseviewmodel.dart';
import 'package:instagram_clone/view/screens/notifications/notification_screen.dart';
import 'package:instagram_clone/view/widget/post_widget/postcard.dart';
import 'package:instagram_clone/viewmodel/controller/pages/home_controller.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Instagram",
              style: TextStyle(
                fontFamily: "Italic",
              ),
            ),
            centerTitle: true,
            actions: [
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ActivityFeedScreen()));
                },
                child: const Icon(
                  Icons.notifications,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          body: Consumer<HomeController>(
            builder: (context, provider, child) {
              if (provider.state == ViewState.loading &&
                  provider.posts.isEmpty) {
                // Show loading indicator while fetching the first batch of posts
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              } else if (provider.posts.isEmpty) {
                // Show 'No Post Available' if there are no posts
                return RefreshIndicator(
                  color: Colors.black,
                  onRefresh: () async {
                    await provider.refreshPosts();
                  },
                  child: ListView(
                    children: const [
                      Center(
                        child: Text("No Post Available"),
                      ),
                    ],
                  ),
                );
              } else {
                // Show the posts with pull-to-refresh functionality
                return RefreshIndicator(
                  color: Colors.black,
                  onRefresh: () async {
                    await provider.refreshPosts();
                  },
                  child: ListView.builder(
                    controller: provider.scrollController,
                    itemCount: provider.posts.length +
                        (provider.state == ViewState.loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          ),
                        );
                      }

                      return Postcard(
                        post: provider.posts[index]['post'],
                        user: provider.posts[index]['user'],
                      );
                    },
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }
}
