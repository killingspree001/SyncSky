import 'package:flutter/material.dart';
import '../models/weather_models.dart';

class WeatherBackground extends StatelessWidget {
  final WeatherCondition condition;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getColors(),
        ),
      ),
      child: Stack(
        children: [
          _buildEffect(),
          child,
        ],
      ),
    );
  }

  List<Color> _getColors() {
    switch (condition) {
      case WeatherCondition.sunny:
        return [
          const Color(0xFFF59E0B),
          const Color(0xFFD97706),
        ];
      case WeatherCondition.partlyCloudy:
        return [
          const Color(0xFF6366F1),
          const Color(0xFF4F46E5),
        ];
      case WeatherCondition.cloudy:
        return [
          const Color(0xFF64748B),
          const Color(0xFF475569),
        ];
      case WeatherCondition.rain:
        return [
          const Color(0xFF334155),
          const Color(0xFF1E293B),
        ];
      case WeatherCondition.thunderstorm:
        return [
          const Color(0xFF1E293B),
          const Color(0xFF0F172A),
        ];
      case WeatherCondition.snow:
        return [
          const Color(0xFF94A3B8),
          const Color(0xFF64748B),
        ];
    }
  }

  Widget _buildEffect() {
    switch (condition) {
      case WeatherCondition.rain:
      case WeatherCondition.thunderstorm:
        return const _RainEffect();
      case WeatherCondition.snow:
        return const _SnowEffect();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _RainEffect extends StatefulWidget {
  const _RainEffect();

  @override
  State<_RainEffect> createState() => _RainEffectState();
}

class _RainEffectState extends State<_RainEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RainPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RainPainter extends CustomPainter {
  final double progress;

  _RainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0;

    const dropCount = 100;
    for (var i = 0; i < dropCount; i++) {
      final x = (i * 37) % size.width;
      final yOffset = (i * 123) % size.height;
      final y = (yOffset + progress * size.height) % size.height;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SnowEffect extends StatefulWidget {
  const _SnowEffect();

  @override
  State<_SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<_SnowEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SnowPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SnowPainter extends CustomPainter {
  final double progress;

  _SnowPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    const flakeCount = 50;
    for (var i = 0; i < flakeCount; i++) {
      final x = (i * 41 + progress * 20 * (i % 5)) % size.width;
      final yOffset = (i * 137) % size.height;
      final y = (yOffset + progress * size.height) % size.height;

      canvas.drawCircle(Offset(x, y), 2.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
