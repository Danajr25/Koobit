import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// ─── Cartoony Kids Widget Library ─────────────────────────────────────────
///
/// All class names are retained from the prior cyber-themed library so that
/// the rest of the app swaps in transparently. The styling has been
/// completely reimagined: light surfaces, chunky rounded corners, soft
/// drop shadows, playful 3D bottom-shadow "pressable" buttons.
/// ─────────────────────────────────────────────────────────────────────────

/// A friendly framed card with thick rounded border. Drop-in for `CyberFrame`.
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
    this.borderWidth = 2.5,
    this.cornerSize = 24,
    this.padding = const EdgeInsets.all(20),
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(cornerSize),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: (glowColor ?? borderColor).withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// A soft "sticker" card with offset drop shadow. Drop-in for `GlowCard`.
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
    this.glowIntensity = 0.18,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: glowIntensity),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: glowColor.withValues(alpha: 0.12),
          highlightColor: glowColor.withValues(alpha: 0.06),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A bouncy, 3D-feeling action button with a thick bottom shadow.
/// Drop-in for `CyberButton`.
class CyberButton extends StatefulWidget {
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
    this.height = 56,
    this.isLoading = false,
    this.outlined = false,
  });

  @override
  State<CyberButton> createState() => _CyberButtonState();
}

class _CyberButtonState extends State<CyberButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final bg = widget.outlined ? AppColors.surface : widget.color;
    final fg = widget.outlined ? widget.color : widget.textColor;
    final shadowColor = _darken(widget.color, 0.18);

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        height: widget.height,
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: enabled ? bg : AppColors.border,
          borderRadius: BorderRadius.circular(22),
          border: widget.outlined
              ? Border.all(color: widget.color, width: 2.5)
              : null,
          boxShadow: enabled && !widget.outlined
              ? [
                  BoxShadow(
                    color: shadowColor,
                    offset: Offset(0, _pressed ? 0 : 5),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.25),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: widget.isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 22, color: fg),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      widget.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: fg,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

/// A friendly pill-shaped text field. Drop-in for `CyberTextField`.
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
        fontWeight: FontWeight.w600,
        fontFamily: 'Nunito',
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textLight,
          fontFamily: 'Nunito',
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: accentColor)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: accentColor, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error, width: 2.5),
        ),
      ),
    );
  }
}

/// A gentle breathing/bobbing wrapper (re-themed from glow pulse).
/// Drop-in for `PulsingGlow`.
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final Duration duration;

  const PulsingGlow({
    super.key,
    required this.child,
    this.glowColor = AppColors.primary,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.04).animate(
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
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// A floating bubble decoration that drifts across the screen.
/// (Replaces the old scanning-line. Same name.)
class ScanningLine extends StatefulWidget {
  final double height;
  final Color color;
  final Duration duration;

  const ScanningLine({
    super.key,
    this.height = 24,
    this.color = AppColors.primary,
    this.duration = const Duration(seconds: 6),
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
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
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
        final t = _controller.value;
        return Positioned(
          top: MediaQuery.of(context).size.height * (1 - t),
          left: MediaQuery.of(context).size.width *
              (0.1 + 0.8 * ((t * 3) % 1.0)),
          child: Opacity(
            opacity: (1 - t).clamp(0.0, 0.6),
            child: Container(
              width: widget.height,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A soft polka-dot/cloud-pattern background. Drop-in for `CyberGridBackground`.
class CyberGridBackground extends StatelessWidget {
  final Color gridColor;
  final double gridSpacing;
  final Widget? child;

  const CyberGridBackground({
    super.key,
    this.gridColor = AppColors.primary,
    this.gridSpacing = 40,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotsPainter(
        dotColor: gridColor,
        spacing: gridSpacing,
      ),
      child: child,
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;

  _DotsPainter({required this.dotColor, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor.withValues(alpha: 0.08);
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 2.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A chunky rounded progress ring. Drop-in for `CyberProgress`.
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
    this.strokeWidth = 10,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: backgroundColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

/// A friendly stat card with a colored icon bubble. Drop-in for `CyberStatCard`.
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
      glowIntensity: 0.12,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
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
