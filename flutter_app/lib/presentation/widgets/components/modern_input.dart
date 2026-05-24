import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

/// Premium Modern Input Field Component
/// Features smooth animations, elegant design, and validation
class ModernInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isMultiline;
  final bool isSearch;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSubmitted;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;

  const ModernInput({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.isPassword = false,
    this.isMultiline = false,
    this.isSearch = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.contentPadding,
  });

  @override
  State<ModernInput> createState() => _ModernInputState();
}

class _ModernInputState extends State<ModernInput> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: _isFocused
                  ? ThemeConfig.primaryColor
                  : theme.textTheme.titleSmall?.color,
            ),
          ),
          const SizedBox(height: ThemeConfig.spacingSmall),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.enabled
                ? (isDark
                    ? ThemeConfig.darkSurfaceVariant
                    : ThemeConfig.surfaceVariant)
                : (isDark
                    ? ThemeConfig.darkSurfaceVariant.withOpacity(0.5)
                    : ThemeConfig.surfaceVariant.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
            border: Border.all(
              color: _isFocused
                  ? ThemeConfig.primaryColor
                  : (isDark
                      ? ThemeConfig.darkBorder
                      : ThemeConfig.borderColor),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: ThemeConfig.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            obscureText: _obscureText,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            keyboardType: widget.keyboardType,
            maxLines: widget.isMultiline ? (widget.maxLines ?? 5) : 1,
            maxLength: widget.maxLength,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: widget.enabled
                  ? theme.textTheme.bodyLarge?.color
                  : theme.textTheme.bodyDisabled?.color,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? ThemeConfig.primaryColor
                          : theme.textTheme.bodySmall?.color,
                      size: 20,
                    )
                  : (widget.isSearch
                      ? Icon(
                          Icons.search,
                          color: _isFocused
                              ? ThemeConfig.primaryColor
                              : theme.textTheme.bodySmall?.color,
                          size: 20,
                        )
                      : null),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: theme.textTheme.bodySmall?.color,
                        size: 20,
                      ),
                      onPressed: _togglePasswordVisibility,
                    )
                  : (widget.suffixIcon != null
                      ? IconButton(
                          icon: Icon(
                            widget.suffixIcon,
                            color: _isFocused
                                ? ThemeConfig.primaryColor
                                : theme.textTheme.bodySmall?.color,
                            size: 20,
                          ),
                          onPressed: widget.onSuffixIconTap,
                        )
                      : null),
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.spacingMedium,
                    vertical: ThemeConfig.spacingMedium,
                  ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              counterText: '',
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
          ),
        ),
      ],
    );
  }
}

/// Premium Search Input with animated clear button
class ModernSearchInput extends StatefulWidget {
  final String hint;
  final void Function(String) onChanged;
  final void Function(String)? onSubmitted;
  final TextEditingController? controller;

  const ModernSearchInput({
    super.key,
    required this.hint,
    required this.onChanged,
    this.onSubmitted,
    this.controller,
  });

  @override
  State<ModernSearchInput> createState() => _ModernSearchInputState();
}

class _ModernSearchInputState extends State<ModernSearchInput> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
    widget.onChanged(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? ThemeConfig.darkSurfaceVariant
            : ThemeConfig.surfaceVariant,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusFull),
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: widget.onSubmitted,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    size: 20,
                  ),
                  onPressed: _clearText,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ThemeConfig.spacingMedium,
            vertical: ThemeConfig.spacingMedium,
          ),
        ),
      ),
    );
  }
}
