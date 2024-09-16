import 'package:flutter/material.dart';

class ResponsiveSizes {
  static height(BuildContext context, double height) {
    return MediaQuery.of(context).size.height * height;
  }

  static width(BuildContext context, double width) {
    return MediaQuery.of(context).size.width * width;
  }

  static verticalSizebox(context,height) {
    return SizedBox(
      height: ResponsiveSizes.height(context, height),
    );
  }

  static horizentalSizebox(context,width) {
    return SizedBox(
      width: ResponsiveSizes.width(context, width),
    );
  }
}
