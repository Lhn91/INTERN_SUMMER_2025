import 'package:flutter/material.dart';

class LeftJoystick extends StatelessWidget {
  final ValueChanged<Offset> onDirectionChanged;
  final double size;

  const LeftJoystick({
    Key? key,
    required this.onDirectionChanged,
    this.size = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _JoystickBase(
      size: size,
      onDirectionChanged: onDirectionChanged,
      backgroundColor: Colors.blue.withOpacity(0.2),
      stickColor: Colors.blue,
    );
  }
}

class RightJoystick extends StatelessWidget {
  final ValueChanged<Offset> onDirectionChanged;
  final double size;

  const RightJoystick({
    Key? key,
    required this.onDirectionChanged,
    this.size = 150,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _JoystickBase(
      size: size,
      onDirectionChanged: onDirectionChanged,
      backgroundColor: Colors.orange.withOpacity(0.2),
      stickColor: Colors.orange,
    );
  }
}

class _JoystickBase extends StatefulWidget {
  final ValueChanged<Offset> onDirectionChanged;
  final double size;
  final Color backgroundColor;
  final Color stickColor;

  const _JoystickBase({
    required this.onDirectionChanged,
    required this.size,
    required this.backgroundColor,
    required this.stickColor,
    Key? key,
  }) : super(key: key);

  @override
  __JoystickBaseState createState() => __JoystickBaseState();
}

class __JoystickBaseState extends State<_JoystickBase> {
  Offset _stickPosition = Offset.zero;
  double _maxDistance = 0;

  @override
  Widget build(BuildContext context) {
    _maxDistance = widget.size / 2 - 30;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.backgroundColor,
      ),
      child: GestureDetector(
        onPanStart: _onDragStart,
        onPanUpdate: _onDragUpdate,
        onPanEnd: _onDragEnd,
        child: Center(
          child: Transform.translate(
            offset: _stickPosition,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.stickColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _updatePosition(details.localPosition);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _updatePosition(details.localPosition);
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _stickPosition = Offset.zero;
    });
    widget.onDirectionChanged(Offset.zero);
  }

  void _updatePosition(Offset localPosition) {
    final center = widget.size / 2;
    final delta = localPosition - Offset(center, center);
    final distance = delta.distance;

    Offset newPosition =
        distance > _maxDistance ? delta * (_maxDistance / distance) : delta;

    setState(() {
      _stickPosition = newPosition;
    });

    // Normalize to -1 to 1 range
    final normalizedX = newPosition.dx / _maxDistance;
    final normalizedY = -newPosition.dy / _maxDistance; // Invert Y axis

    widget.onDirectionChanged(Offset(normalizedX, normalizedY));
  }
}
