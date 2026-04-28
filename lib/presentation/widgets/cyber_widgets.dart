import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// A HUD-style frame with tech corners and optional glow effect
class CyberFrame extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color? glowColor;
  final double borderWidth;
  final double cornerSize;
  final EdgeInsetsGeometry padding;
  final bool showGlow;

  const CyberFrame({
    super.key,
    required this.child,
    this.borderColor = AppColors.primary,
    this.glowColor,
    this.borderWidth = 1.5,
    this.cornerSize = 12,
    this.padding = const EdgeInsets.all(16),
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withOpacity(0.5),
          width: borderWidth,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: (glowColor ?? borderColor).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _CyberFramePainter(
          borderColor: borderColor,
          cornerSize: cornerSize,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _CyberFramePainter extends CustomPainter {
  final Color borderColor;
  final double cornerSize;

  _CyberFramePainter({
    required this.borderColor,
    required this.cornerSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Top-left corner
    canvas.drawLine(
      const Offset(0, 0),
      Offset(cornerSize, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, cornerSize),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerSize, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerSize),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerSize, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerSize),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerSize, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A card with glowing border effect
class GlowCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.glowIntensity = 0.4,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 12,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(glowIntensity),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A cyber-styled button with neon glow
class CyberButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final double height;
  final bool isLoading;
  final bool outlined;

  const CyberButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    this.icon,
    this.height = 52,
    this.isLoading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.transparent : color,
          foregroundColor: outlined ? color : textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: outlined
                ? BorderSide(color: color, width: 1.5)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    outlined ? color : textColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// A cyber-styled text field
class CyberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color accentColor;

  const CyberTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.accentColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
        ),
        hintStyle: TextStyle(
          color: AppColors.textLight,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: accentColor)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: accentColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// A pulsing glow animation wrapper
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;

  const PulsingGlow({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.glowColor.withOpacity(_animation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// A scanning line animation for cyber effect
class ScanningLine extends StatefulWidget {
  final double height;
  final Color color;
  final Duration duration;

  const ScanningLine({
    super.key,
    this.height = 2,
    this.color = AppColors.primary,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<ScanningLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
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
        return Positioned(
          top: _controller.value * MediaQuery.of(context).size.height,
          left: 0,
          right: 0,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withOpacity(0),
                  widget.color.withOpacity(0.8),
                  widget.color.withOpacity(0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Grid background pattern for cyber effect
class CyberGridBackground extends StatelessWidget {
  final Color gridColor;
  final double gridSpacing;
  final Widget? child;

  const CyberGridBackground({
    super.key,
    this.gridColor = AppColors.border,
    this.gridSpacing = 30,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(
        gridColor: gridColor,
        gridSpacing: gridSpacing,
      ),
      child: child,
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color gridColor;
  final double gridSpacing;

  _GridPainter({
    required this.gridColor,
    required this.gridSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A circular progress indicator with cyber styling
class CyberProgress extends StatelessWidget {
  final double value;
  final double size;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final Widget? child;

  const CyberProgress({
    super.key,
    required this.value,
    this.size = 100,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.border,
    this.strokeWidth = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// A stat card with cyber styling
class CyberStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const CyberStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      glowColor: color,
      glowIntensity: 0.2,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
