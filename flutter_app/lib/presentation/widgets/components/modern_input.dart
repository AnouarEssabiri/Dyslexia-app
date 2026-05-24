import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

/// Premium Modern Input Field Component
/// Features smooth animations, elegant design, and validation
class ModernInput extends StatefulWidget {

  const ModernInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.isMultiline = false,
    this.prefix,
    this.suffix,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.maxLines,
    this.enabled = true,
    this.focusNode,
  });
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isMultiline;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  State<ModernInput> createState() => _ModernInputState();
}

class _ModernInputState extends State<ModernInput> {
  late bool _obscureText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
          },
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: _obscureText,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            maxLines: widget.isMultiline ? (widget.maxLines ?? 5) : 1,
            enabled: widget.enabled,
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 15,
              color: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefix != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: widget.prefix,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 20,
                        color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : widget.suffix,
              filled: true,
              fillColor: _isFocused
                  ? (isDark ? ThemeConfig.darkSurface : Colors.white)
                  : (isDark ? ThemeConfig.darkSurfaceVariant : ThemeConfig.surfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                borderSide: BorderSide(
                  color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                borderSide: const BorderSide(
                  color: ThemeConfig.primaryColor,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
