import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/viewmodel/controller/mobileviewprovider/mobile_view_controller.dart';
import 'package:provider/provider.dart';

class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => MobileViewController(),
        child: Scaffold(body:
            Consumer<MobileViewController>(builder: (context, provider, child) {
          return PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: provider.pageController,
            children: provider.pages,
            onPageChanged: (int index) {
              provider.onpageChange(index);
            },
          );
        }), bottomNavigationBar:
            Consumer<MobileViewController>(builder: (context, provider, child) {
          return CupertinoTabBar(
              backgroundColor: mobileBackgroundColor,
              onTap: (index) {
                provider.changeIndex(index);
              },
              activeColor: primaryColor,
              inactiveColor: secondaryColor,
              currentIndex: provider.currentIndex,
              items: provider.bottomNavigationBarItems);
        })));
  }
}
