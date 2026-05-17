import 'package:flutter/material.dart';

enum SwipeDirection { left, right }

/// Reusable Tinder-style deck.
/// - `itemCount`: total cards to render top-down
/// - `cardBuilder`: how each index is rendered
/// - `onSwipe`: fired with the swiped index + direction
/// - `onEmpty`: fired once when the last card leaves
class SwipeCardDeck extends StatefulWidget {
  const SwipeCardDeck({
    required this.itemCount,
    required this.cardBuilder,
    required this.onSwipe,
    this.onEmpty,
    super.key,
  });

  final int itemCount;
  final Widget Function(BuildContext, int index) cardBuilder;
  final void Function(int index, SwipeDirection direction) onSwipe;
  final VoidCallback? onEmpty;

  @override
  State<SwipeCardDeck> createState() => SwipeCardDeckState();
}

class SwipeCardDeckState extends State<SwipeCardDeck>
    with SingleTickerProviderStateMixin {
  int _topIndex = 0;
  Offset _drag = Offset.zero;
  bool _animating = false;
  late AnimationController _animation;
  Animation<Offset>? _flyOut;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        setState(() {
          _drag = _flyOut?.value ?? _drag;
        });
      });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_animating) return;
    setState(() => _drag += d.delta);
  }

  void _onPanEnd(DragEndDetails d) {
    if (_animating) return;
    const threshold = 120.0;
    if (_drag.dx > threshold) {
      _completeSwipe(SwipeDirection.right);
    } else if (_drag.dx < -threshold) {
      _completeSwipe(SwipeDirection.left);
    } else {
      _flyOut = Tween<Offset>(begin: _drag, end: Offset.zero).animate(
        CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic),
      );
      _animating = true;
      _animation.forward(from: 0).whenComplete(() {
        _animating = false;
        _drag = Offset.zero;
      });
    }
  }

  /// Programmatic swipe (used by the two action buttons under the deck).
  void swipe(SwipeDirection direction) => _completeSwipe(direction);

  void _completeSwipe(SwipeDirection direction) {
    if (_topIndex >= widget.itemCount) return;
    final endX =
        direction == SwipeDirection.right ? 1200.0 : -1200.0;
    _flyOut = Tween<Offset>(
      begin: _drag,
      end: Offset(endX, _drag.dy),
    ).animate(CurvedAnimation(parent: _animation, curve: Curves.easeIn));
    _animating = true;
    _animation.forward(from: 0).whenComplete(() {
      widget.onSwipe(_topIndex, direction);
      setState(() {
        _topIndex++;
        _drag = Offset.zero;
        _animating = false;
      });
      if (_topIndex >= widget.itemCount) widget.onEmpty?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_topIndex >= widget.itemCount) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "You're all set.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    // Render up to 3 cards stacked (current + 2 peeks for depth).
    final cards = <Widget>[];
    final maxStack = 3;
    final visible = (widget.itemCount - _topIndex).clamp(0, maxStack);

    for (var offset = visible - 1; offset >= 0; offset--) {
      final idx = _topIndex + offset;
      final isTop = offset == 0;
      final scale = 1 - (offset * 0.04);
      final translationY = offset * 12.0;

      Widget card = widget.cardBuilder(context, idx);

      if (isTop) {
        final angle = (_drag.dx / 400).clamp(-0.25, 0.25);
        card = Transform.translate(
          offset: _drag,
          child: Transform.rotate(
            angle: angle,
            child: Stack(
              children: [
                card,
                // Decision badges
                if (_drag.dx > 24)
                  Positioned(
                    top: 24,
                    left: 24,
                    child: _DecisionBadge(
                      label: 'LEARN',
                      color: Colors.green.shade600,
                      opacity: (_drag.dx / 150).clamp(0.0, 1.0),
                    ),
                  ),
                if (_drag.dx < -24)
                  Positioned(
                    top: 24,
                    right: 24,
                    child: _DecisionBadge(
                      label: 'SKIP',
                      color: Colors.red.shade600,
                      opacity: (-_drag.dx / 150).clamp(0.0, 1.0),
                    ),
                  ),
              ],
            ),
          ),
        );

        card = GestureDetector(
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: card,
        );
      } else {
        card = Transform.translate(
          offset: Offset(0, translationY),
          child: Transform.scale(scale: scale, child: card),
        );
      }
      cards.add(Positioned.fill(child: card));
    }

    return Stack(children: cards);
  }
}

class _DecisionBadge extends StatelessWidget {
  const _DecisionBadge({
    required this.label,
    required this.color,
    required this.opacity,
  });
  final String label;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: label == 'LEARN' ? -0.3 : 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}