import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A clean OTP entry field rendered as [length] boxes backed by a single
/// hidden text field (robust paste + auto-fill + backspace handling).
class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autoFocus;
  final bool enabled;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.autoFocus = true,
    this.enabled = true,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    final value = _controller.text;
    setState(() {});
    widget.onChanged?.call(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hidden input that actually receives keystrokes / SMS autofill.
        Opacity(
          opacity: 0,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: widget.autoFocus,
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: widget.length,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(widget.length),
            ],
            autofillHints: const [AutofillHints.oneTimeCode],
          ),
        ),
        GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, _buildCell),
          ),
        ),
      ],
    );
  }

  Widget _buildCell(int index) {
    final text = _controller.text;
    final hasChar = index < text.length;
    final isActive = index == text.length && _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: hasChar ? AppColors.blueTint : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.primaryBlue
              : hasChar
                  ? AppColors.primaryBlueLight
                  : AppColors.divider,
          width: isActive ? 2 : 1.4,
        ),
      ),
      child: Text(
        hasChar ? text[index] : '',
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
