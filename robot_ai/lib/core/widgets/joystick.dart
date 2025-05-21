import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Joystick extends HookWidget {
  final Function(Offset) onDirectionChanged;
  final double size;
  final double innerCircleSize;

  const Joystick({
    Key? key, 
    required this.onDirectionChanged,
    this.size = 200.0,
    this.innerCircleSize = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final position = useState(Offset.zero);
    final isDragging = useState(false);
    final outerRadius = size / 2;
    final innerRadius = innerCircleSize / 2;
    
    void updatePosition(Offset newPosition) {
      // Giới hạn vị trí trong vòng tròn ngoài
      final dx = newPosition.dx;
      final dy = newPosition.dy;
      final distance = newPosition.distance;
      
      if (distance > outerRadius - innerRadius) {
        final angle = math.atan2(dy, dx);
        final limitedDx = (outerRadius - innerRadius) * math.cos(angle);
        final limitedDy = (outerRadius - innerRadius) * math.sin(angle);
        position.value = Offset(limitedDx, limitedDy);
      } else {
        position.value = newPosition;
      }
      
      // Chuẩn hóa giá trị để trả về -1 đến 1
      final normalizedX = position.value.dx / (outerRadius - innerRadius);
      final normalizedY = position.value.dy / (outerRadius - innerRadius);
      
      onDirectionChanged(Offset(normalizedX, normalizedY));
    }
    
    void resetPosition() {
      position.value = Offset.zero;
      onDirectionChanged(Offset.zero);
    }

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade300,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: GestureDetector(
          onPanStart: (details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final center = Offset(outerRadius, outerRadius);
            final localPosition = renderBox.globalToLocal(details.globalPosition) - center;
            updatePosition(localPosition);
            isDragging.value = true;
          },
          onPanUpdate: (details) {
            if (isDragging.value) {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final center = Offset(outerRadius, outerRadius);
              final localPosition = renderBox.globalToLocal(details.globalPosition) - center;
              updatePosition(localPosition);
            }
          },
          onPanEnd: (details) {
            resetPosition();
            isDragging.value = false;
          },
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: innerCircleSize,
                  height: innerCircleSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: position.value,
                  child: Container(
                    width: innerCircleSize,
                    height: innerCircleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.shade700,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.control_camera, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 