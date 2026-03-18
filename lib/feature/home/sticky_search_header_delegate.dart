import 'package:flutter/material.dart';

class StickySearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickySearchHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => 76.0;

  @override
  double get minExtent => 76.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
