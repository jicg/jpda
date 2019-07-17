import 'package:flutter/material.dart';
import 'dart:math' as math;

const double _kFrontHeadingHeight = 30; // front layer beveled rectangle
const double _kBackAppBarHeight = 56.0; // back layer (options) appbar height
const double _kBackAppBarWidth = 56.0;
const double _kFrontClosedHeight = 30;

class DetailTitleWidget extends StatefulWidget {
  final Widget backTitle;
  final Widget frontTitle;
  final List<IconButton> actions;
  final Widget backBody;
  final bool showCloseBtn;

  final Widget leading;
  final Widget frontHeading;
  final Widget frontBody;

  const DetailTitleWidget(
      {Key key,
      this.actions = const [],
      @required this.backBody,
      @required this.backTitle,
      @required this.frontTitle,
      @required this.frontHeading,
      @required this.frontBody,
      @required this.leading,
      this.showCloseBtn = true})
      : super(key: key);

  @override
  _DetailTitleWidgetState createState() => _DetailTitleWidgetState();
}

class _DetailTitleWidgetState extends State<DetailTitleWidget>
    with SingleTickerProviderStateMixin {
  GlobalKey _key = GlobalKey(debugLabel: "DetailTitle");

  AnimationController _controller;
  Animation<double> _frontOpacity;

//  static final Animatable<double> _frontOpacityTween =
//      Tween<double>(begin: 0.0, end: 1.0).chain(
//          CurveTween(curve: const Interval(0.0, 0.4, curve: Curves.easeInOut)));
  final Animatable<BorderRadius> _kFrontHeadingBevelRadius = BorderRadiusTween(
    end: const BorderRadius.only(
      topLeft: Radius.circular(0.0),
      topRight: Radius.circular(0.0),
    ),
    begin: const BorderRadius.only(
      topLeft: Radius.circular(_kFrontHeadingHeight),
      topRight: Radius.circular(_kFrontHeadingHeight),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(microseconds: 100));
//    _frontOpacity = _controller.drive(_frontOpacityTween);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _backdropHeight {
    // Warning: this can be safely called from the event handlers but it may not be called at build time.
    final RenderBox renderBox = _key.currentContext.findRenderObject();
    return math.max(
        0.0, renderBox.size.height - _kFrontClosedHeight - _kBackAppBarHeight);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -=
        details.primaryDelta / (_backdropHeight ?? details.primaryDelta);
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;
    if (details != null) {
      final double flingVelocity =
          details.velocity.pixelsPerSecond.dy / _backdropHeight;
      if (flingVelocity < 0.0)
        _controller.fling(velocity: math.max(2.0, -flingVelocity));
      else if (flingVelocity > 0.0) {
        _controller.fling(velocity: math.min(-2.0, -flingVelocity));
      } else {
        _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
      }
    } else {
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
    }
//
  }

  void _toggleFrontLayer() {
    if (!_controller.isAnimating) {
      final AnimationStatus status = _controller.status;
      final bool isOpen = status == AnimationStatus.completed ||
          status == AnimationStatus.forward;
      _controller.fling(velocity: isOpen ? -2 : 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildStack);
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    final Animation<RelativeRect> frontRelativeRect =
        _controller.drive(RelativeRectTween(
      begin: RelativeRect.fromLTRB(
          0.0,
          constraints.biggest.height - _kBackAppBarHeight - _kFrontClosedHeight,
          0.0,
          0.0),
      end: const RelativeRect.fromLTRB(0.0, _kBackAppBarHeight, 0.0, 0.0),
    ));
    List<Widget> layers = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _BackAppBar(
            leading: widget.leading,
            title: _CrossFadeTransition(
              progress: _controller,
              alignment: AlignmentDirectional.centerStart,
              child0: Semantics(namesRoute: true, child: widget.frontTitle),
              child1: Semantics(namesRoute: true, child: widget.backTitle),
            ),
            trailing: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[]
                ..addAll(widget.actions)
                ..add(widget.showCloseBtn
                    ? IconButton(
                        icon: AnimatedIcon(
                            icon: AnimatedIcons.close_menu,
                            progress: _controller),
                        onPressed: _toggleFrontLayer,
                      )
                    : Container()),
            ),
          ),
          Expanded(
            child: Visibility(
              child: DefaultTextStyle(
                style: Theme.of(context).primaryTextTheme.title,
                child: widget.backBody,
              ),
              visible: _controller.status != AnimationStatus.completed,
              maintainState: true,
            ),
          ),
          SizedBox(height: _kFrontClosedHeight + _kBackAppBarHeight)
        ],
      ),
      PositionedTransition(
          rect: frontRelativeRect,
          child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                return Container(
                    padding: EdgeInsets.only(top: 48),
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            (1.0 - _controller.value) * _kFrontClosedHeight +
                                18),
                        topRight: Radius.circular(
                            (1.0 - _controller.value) * _kFrontClosedHeight +
                                18),
                      ),
                    ),
                    child: _TappableWhileStatusIs(AnimationStatus.completed,
                        controller: _controller,
                        child: Visibility(
                           visible: _controller.status == AnimationStatus.completed, child: widget.frontBody)));
              })),
    ];
    layers.add(
      PositionedTransition(
        rect: frontRelativeRect,
        child: ExcludeSemantics(
            child: Container(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleFrontLayer,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                      (1.0 - _controller.value) * _kFrontClosedHeight + 18),
                  topRight: Radius.circular(
                      (1.0 - _controller.value) * _kFrontClosedHeight + 18),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 18,
                    child: Center(
                        child: Container(
                      color: Colors.grey,
                      width: 45,
                      height: 6,
                    )),
                  ),
                  Container(
                    height: 30,
                    child: widget.frontHeading,
                  ),
                  Divider(
                    height: 0,
                  )
                ],
              ),
            ),
          ),
        )),
      ),
    );

    return Stack(
      key: _key,
      children: layers,
    );
  }
}

class _CrossFadeTransition extends AnimatedWidget {
  const _CrossFadeTransition({
    Key key,
    this.alignment = Alignment.center,
    Animation<double> progress,
    this.child0,
    this.child1,
  }) : super(key: key, listenable: progress);

  final AlignmentGeometry alignment;
  final Widget child0;
  final Widget child1;

  @override
  Widget build(BuildContext context) {
    final Animation<double> progress = listenable;

    final double opacity1 = CurvedAnimation(
      parent: ReverseAnimation(progress),
      curve: const Interval(0.5, 1.0),
    ).value;

    final double opacity2 = CurvedAnimation(
      parent: progress,
      curve: const Interval(0.5, 1.0),
    ).value;

    return Stack(
      alignment: alignment,
      children: <Widget>[
        Opacity(
          opacity: opacity1,
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: child1,
          ),
        ),
        Opacity(
          opacity: opacity2,
          child: Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: child0,
          ),
        ),
      ],
    );
  }
}

class _BackAppBar extends StatelessWidget {
  const _BackAppBar({
    Key key,
    this.leading = const SizedBox(width: 56.0),
    @required this.title,
    this.trailing,
  })  : assert(leading != null),
        assert(title != null),
        super(key: key);

  final Widget leading;
  final Widget title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[
      Expanded(
        child: Container(
          alignment: Alignment.centerLeft,
          child: leading,
        ),
      ),
      title,
    ];

    if (trailing != null) {
      children.add(
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: trailing,
          ),
        ),
      );
    }

    final ThemeData theme = Theme.of(context);

    return IconTheme.merge(
      data: theme.primaryIconTheme,
      child: DefaultTextStyle(
        style: theme.primaryTextTheme.title,
        child: SizedBox(
          height: _kBackAppBarHeight,
          child: Row(children: children),
        ),
      ),
    );
  }
}

class _TappableWhileStatusIs extends StatefulWidget {
  const _TappableWhileStatusIs(
    this.status, {
    Key key,
    this.controller,
    this.child,
  }) : super(key: key);

  final AnimationController controller;
  final AnimationStatus status;
  final Widget child;

  @override
  _TappableWhileStatusIsState createState() => _TappableWhileStatusIsState();
}

class _TappableWhileStatusIsState extends State<_TappableWhileStatusIs> {
  bool _active;

  @override
  void initState() {
    super.initState();
    widget.controller.addStatusListener(_handleStatusChange);
    _active = widget.controller.status == widget.status;
  }

  @override
  void dispose() {
    widget.controller.removeStatusListener(_handleStatusChange);
    super.dispose();
  }

  void _handleStatusChange(AnimationStatus status) {
    final bool value = widget.controller.status == widget.status;
    if (_active != value) {
      setState(() {
        _active = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !_active,
      child: widget.child,
    );
  }
}
