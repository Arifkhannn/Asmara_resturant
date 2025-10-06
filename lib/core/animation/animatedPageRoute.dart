import 'package:flutter/material.dart';


class AnimatedPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  AnimatedPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const beginOffset = Offset(0.1, 0.0); // from right side
            const endOffset = Offset.zero;
            final tween = Tween(begin: beginOffset, end: endOffset)
                .chain(CurveTween(curve: Curves.easeInOut));

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
        );
}
