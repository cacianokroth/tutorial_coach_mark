library tutorial_coach_mark;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/util.dart';
import 'package:tutorial_coach_mark/src/widgets/tutorial_coach_mark_widget.dart';

export 'package:tutorial_coach_mark/src/target/target_content.dart';
export 'package:tutorial_coach_mark/src/target/target_focus.dart';
export 'package:tutorial_coach_mark/src/target/target_position.dart';
export 'package:tutorial_coach_mark/src/util.dart';

class TutorialCoachMark {
  final List<TargetFocus> targets;
  final FutureOr<void> Function(TargetFocus)? onClickTarget;
  final OnTutorialCoachMarkFocusChanged? onFocusChanged;
  final FutureOr<void> Function(TargetFocus, TapDownDetails)? onClickTargetWithTapPosition;
  final FutureOr<void> Function(TargetFocus)? onClickOverlay;
  final Function()? onFinish;
  final double paddingFocus;
  final Function()? onSkip;
  final Color colorShadow;
  final double opacityShadow;
  final GlobalKey<TutorialCoachMarkWidgetState> _widgetKey = GlobalKey();
  final Duration focusAnimationDuration;
  final Duration unFocusAnimationDuration;
  final Duration pulseAnimationDuration;
  final bool pulseEnable;
  final ImageFilter? imageFilter;
  final bool? shouldScrollToTarget;
  final TutorialCoachMarkNavigationBarBuilder? navigationBarBuilder;

  OverlayEntry? _overlayEntry;

  TutorialCoachMark({
    required this.targets,
    this.navigationBarBuilder,
    this.colorShadow = Colors.black,
    this.onClickTarget,
    this.onClickTargetWithTapPosition,
    this.onClickOverlay,
    this.onFinish,
    this.paddingFocus = 10,
    this.onSkip,
    this.opacityShadow = 0.8,
    this.focusAnimationDuration = const Duration(milliseconds: 600),
    this.unFocusAnimationDuration = const Duration(milliseconds: 600),
    this.pulseAnimationDuration = const Duration(milliseconds: 500),
    this.pulseEnable = true,
    this.onFocusChanged,
    this.imageFilter,
    this.shouldScrollToTarget,
  }) : assert(opacityShadow >= 0 && opacityShadow <= 1);

  OverlayEntry _buildOverlay({bool rootOverlay = false}) {
    return OverlayEntry(
      builder: (context) {
        return TutorialCoachMarkWidget(
          key: _widgetKey,
          targets: targets,
          clickTarget: onClickTarget,
          onClickTargetWithTapPosition: onClickTargetWithTapPosition,
          clickOverlay: onClickOverlay,
          paddingFocus: paddingFocus,
          onClickSkip: skip,
          colorShadow: colorShadow,
          opacityShadow: opacityShadow,
          focusAnimationDuration: focusAnimationDuration,
          unFocusAnimationDuration: unFocusAnimationDuration,
          pulseAnimationDuration: pulseAnimationDuration,
          pulseEnable: pulseEnable,
          finish: finish,
          rootOverlay: rootOverlay,
          imageFilter: imageFilter,
          navigationBarBuilder: navigationBarBuilder,
          onFocusChanged: onFocusChanged,
          shouldScrollToTarget: shouldScrollToTarget,
        );
      },
    );
  }

  void show({required BuildContext context, bool rootOverlay = false}) {
    OverlayState? overlay = Overlay.of(context, rootOverlay: rootOverlay);
    overlay.let((it) {
      showWithOverlayState(overlay: it, rootOverlay: rootOverlay);
    });
  }

  // `navigatorKey` needs to be the one that you passed to MaterialApp.navigatorKey
  void showWithNavigatorStateKey({
    required GlobalKey<NavigatorState> navigatorKey,
    bool rootOverlay = false,
  }) {
    navigatorKey.currentState?.overlay.let((it) {
      showWithOverlayState(
        overlay: it,
        rootOverlay: rootOverlay,
      );
    });
  }

  void showWithOverlayState({
    required OverlayState overlay,
    bool rootOverlay = false,
  }) {
    postFrame(() => _createAndShow(overlay, rootOverlay: rootOverlay));
  }

  void _createAndShow(
    OverlayState overlay, {
    bool rootOverlay = false,
  }) {
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay(rootOverlay: rootOverlay);
      overlay.insert(_overlayEntry!);
    }
  }

  void finish() {
    onFinish?.call();
    _removeOverlay();
  }

  void skip() {
    onSkip?.call();
    _removeOverlay();
  }

  bool get isShowing => _overlayEntry != null;

  void next() => _widgetKey.currentState?.next();

  void previous() => _widgetKey.currentState?.previous();

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
