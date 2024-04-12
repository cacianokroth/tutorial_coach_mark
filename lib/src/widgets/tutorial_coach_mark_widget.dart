import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/src/target/target_content.dart';
import 'package:tutorial_coach_mark/src/target/target_focus.dart';
import 'package:tutorial_coach_mark/src/target/target_position.dart';
import 'package:tutorial_coach_mark/src/util.dart';
import 'package:tutorial_coach_mark/src/widgets/animated_focus_light.dart';

typedef TutorialCoachMarkNavigationBarBuilder = Widget Function(
  BuildContext context,
  TutorialCoachMarkController controller,
  TargetFocus? currentTarget,
);

typedef OnTutorialCoachMarkFocusChanged = FutureOr Function(
  TargetFocus? previous,
  TargetFocus current,
);

class TutorialCoachMarkWidget extends StatefulWidget {
  const TutorialCoachMarkWidget({
    Key? key,
    required this.targets,
    this.finish,
    this.paddingFocus = 10,
    this.clickTarget,
    this.onClickTargetWithTapPosition,
    this.clickOverlay,
    this.onClickSkip,
    this.colorShadow = Colors.black,
    this.opacityShadow = 0.8,
    this.focusAnimationDuration,
    this.unFocusAnimationDuration,
    this.pulseAnimationDuration,
    this.pulseVariation,
    this.pulseEnable = true,
    this.rootOverlay = false,
    this.imageFilter,
    this.navigationBarBuilder,
    this.onFocusChanged,
    this.shouldScrollToTarget,
  })  : assert(targets.length > 0),
        super(key: key);

  final List<TargetFocus> targets;
  final FutureOr Function(TargetFocus)? clickTarget;
  final OnTutorialCoachMarkFocusChanged? onFocusChanged;
  final FutureOr Function(TargetFocus, TapDownDetails)? onClickTargetWithTapPosition;
  final FutureOr Function(TargetFocus)? clickOverlay;
  final Function()? finish;
  final Color colorShadow;
  final double opacityShadow;
  final double paddingFocus;
  final Function()? onClickSkip;
  final Duration? focusAnimationDuration;
  final Duration? unFocusAnimationDuration;
  final Duration? pulseAnimationDuration;
  final Tween<double>? pulseVariation;
  final bool pulseEnable;
  final bool rootOverlay;
  final bool? shouldScrollToTarget;
  final ImageFilter? imageFilter;
  final TutorialCoachMarkNavigationBarBuilder? navigationBarBuilder;

  @override
  TutorialCoachMarkWidgetState createState() => TutorialCoachMarkWidgetState();
}

class TutorialCoachMarkWidgetState extends State<TutorialCoachMarkWidget>
    implements TutorialCoachMarkController {
  final GlobalKey<AnimatedFocusLightState> _focusLightKey = GlobalKey();
  bool showContent = false;
  TargetFocus? currentTarget;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          AnimatedFocusLight(
            key: _focusLightKey,
            targets: widget.targets,
            finish: widget.finish,
            paddingFocus: widget.paddingFocus,
            colorShadow: widget.colorShadow,
            opacityShadow: widget.opacityShadow,
            focusAnimationDuration: widget.focusAnimationDuration,
            unFocusAnimationDuration: widget.unFocusAnimationDuration,
            pulseAnimationDuration: widget.pulseAnimationDuration,
            pulseVariation: widget.pulseVariation,
            pulseEnable: widget.pulseEnable,
            rootOverlay: widget.rootOverlay,
            imageFilter: widget.imageFilter,
            onFocusChanged: widget.onFocusChanged,
            clickTarget: widget.clickTarget,
            clickTargetWithTapPosition: widget.onClickTargetWithTapPosition,
            clickOverlay: widget.clickOverlay,
            shouldScrollToTarget: widget.shouldScrollToTarget,
            focus: (target) {
              setState(() {
                currentTarget = target;
                showContent = true;
              });
            },
            removeFocus: () {
              setState(() {
                showContent = false;
              });
            },
          ),
          AnimatedOpacity(
            opacity: showContent ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: _buildContents(),
          ),
          if (widget.navigationBarBuilder != null)
            Visibility(
              visible: showContent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: widget.navigationBarBuilder!(
                  context,
                  this,
                  currentTarget,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildContents() {
    if (currentTarget == null) {
      return const SizedBox.shrink();
    }

    List<Widget> children = <Widget>[];

    TargetPosition? target;
    try {
      target = getTargetCurrent(
        currentTarget!,
        rootOverlay: widget.rootOverlay,
      );
    } on NotFoundTargetException catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
    }

    if (target == null) {
      return const SizedBox.shrink();
    }

    var positioned = Offset(
      target.offset.dx + target.size.width / 2,
      target.offset.dy + target.size.height / 2,
    );

    double haloWidth;
    double haloHeight;

    if (currentTarget!.shape == ShapeLightFocus.Circle) {
      haloWidth = target.size.width > target.size.height ? target.size.width : target.size.height;
      haloHeight = haloWidth;
    } else {
      haloWidth = target.size.width;
      haloHeight = target.size.height;
    }

    haloWidth = haloWidth * 0.6 + widget.paddingFocus;
    haloHeight = haloHeight * 0.6 + widget.paddingFocus;

    double weight = 0.0;
    double? top;
    double? bottom;
    double? left;
    double? right;

    children = currentTarget!.contents!.map<Widget>((i) {
      switch (i.align) {
        case ContentAlign.bottom:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = positioned.dy + haloHeight;
            bottom = null;
          }
          break;
        case ContentAlign.top:
          {
            weight = MediaQuery.of(context).size.width;
            left = 0;
            top = null;
            bottom = haloHeight + (MediaQuery.of(context).size.height - positioned.dy);
          }
          break;
        case ContentAlign.left:
          {
            weight = positioned.dx - haloWidth;
            left = 0;
            top = positioned.dy - target!.size.height / 2 - haloHeight;
            bottom = null;
          }
          break;
        case ContentAlign.right:
          {
            left = positioned.dx + haloWidth;
            top = positioned.dy - target!.size.height / 2 - haloHeight;
            bottom = null;
            weight = MediaQuery.of(context).size.width - left!;
          }
          break;
        case ContentAlign.custom:
          {
            left = i.customPosition!.left;
            right = i.customPosition!.right;
            top = i.customPosition!.top;
            bottom = i.customPosition!.bottom;
            weight = MediaQuery.of(context).size.width;
          }
          break;
      }

      return Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: SizedBox(
          width: weight,
          child: Padding(
            padding: i.padding,
            child: i.builder?.call(context, this) ?? (i.child ?? const SizedBox.shrink()),
          ),
        ),
      );
    }).toList();

    return Stack(
      children: children,
    );
  }

  @override
  void skip() => widget.onClickSkip?.call();

  @override
  void next() => _focusLightKey.currentState?.next();

  @override
  void previous() => _focusLightKey.currentState?.previous();
}
