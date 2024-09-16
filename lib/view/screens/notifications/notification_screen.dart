import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/activityfeed.dart';
import 'package:instagram_clone/view/screens/pages/profile_screen.dart';
import 'package:instagram_clone/viewmodel/controller/notifications/notifications.dart';
import 'package:provider/provider.dart';

class ActivityFeedScreen extends StatelessWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mheight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => NotificationsController(),
      builder: (context, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Activity Feed'),
              centerTitle: true,
            ),
            body: Consumer<NotificationsController>(
              builder: (context, provider, child) {
                return StreamBuilder<List<ActivityFeedItem>>(
                  stream: provider.fetchActivityFeed(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error fetching activity feed: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No notifications yet'));
                    }

                    List<ActivityFeedItem> feedItems = snapshot.data!;

                    return ListView.builder(
                      itemCount: feedItems.length,
                      itemBuilder: (context, index) {
                        ActivityFeedItem item = feedItems[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => UserProfileScreen(
                                        userId: item.userId)));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              leading: ClipOval(
                                child: CachedNetworkImage(
                                  height: mheight * 0.07,
                                  width: mheight * 0.07,
                                  fit: BoxFit.cover,
                                  imageUrl: item.userProfileImg,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(CupertinoIcons.person),
                                ),
                              ),
                              title: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: item.username.split(' ').first,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                    const TextSpan(
                                        text:
                                            ' '), // Space between username & text
                                    TextSpan(
                                      text: provider.getActivityText(item),
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle:
                                  Text(provider.formatTime(item.timestamp)),
                              trailing:
                                  item.type == 'like' || item.type == 'comment'
                                      ? CachedNetworkImage(
                                          height: mheight * 0.07,
                                          width: mheight * 0.07,
                                          fit: BoxFit.cover,
                                          imageUrl: item.postImageUrl,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(CupertinoIcons.photo),
                                        )
                                      : null,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ));
      },
    );
  }
}
