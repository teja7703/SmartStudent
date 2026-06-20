import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/otp_input_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  String _otp = '';

  Timer? _resendTimer;
  int _resendSeconds = 0;
  String? _timerStartedFor;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhone => '+91${_phoneController.text.trim()}';

  void _startResendCountdown(String verificationId) {
    if (_timerStartedFor == verificationId) return;
    _timerStartedFor = verificationId;
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      _showSnack('Please enter a valid 10-digit mobile number');
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().sendOtp(_fullPhone);
  }

  void _verifyOtp(AuthCodeSent state) {
    if (_otp.length != 6) {
      _showSnack('Please enter the 6-digit OTP');
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().verifyOtp(
          verificationId: state.verificationId,
          smsCode: _otp,
          phoneNumber: state.phoneNumber,
          resendToken: state.resendToken,
        );
  }

  void _resendOtp(AuthCodeSent state) {
    if (_resendSeconds > 0) return;
    _timerStartedFor = null;
    context.read<AuthCubit>().sendOtp(
          state.phoneNumber,
          resendToken: state.resendToken,
        );
  }

  void _changeNumber() {
    _otp = '';
    _resendTimer?.cancel();
    _timerStartedFor = null;
    _resendSeconds = 0;
    context.read<AuthCubit>().resetToPhoneEntry();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentRed,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthError) {
            _showSnack(state.message);
          } else if (state is AuthCodeSent) {
            _startResendCountdown(state.verificationId);
          }
        },
        builder: (context, state) {
          final isOtpStep = state is AuthCodeSent ||
              (state is AuthOtpInProgress && state.verificationId != null);

          return SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.vertical,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: isOtpStep
                        ? _OtpView(
                            state: state,
                            otpLength: 6,
                            resendSeconds: _resendSeconds,
                            onOtpChanged: (v) => _otp = v,
                            onOtpCompleted: (v) {
                              _otp = v;
                              if (state is AuthCodeSent) _verifyOtp(state);
                            },
                            onVerify: () {
                              if (state is AuthCodeSent) _verifyOtp(state);
                            },
                            onResend: () {
                              if (state is AuthCodeSent) _resendOtp(state);
                            },
                            onChangeNumber: _changeNumber,
                          )
                        : _PhoneView(
                            phoneController: _phoneController,
                            onSendOtp: _sendOtp,
                            onGoogle: () =>
                                context.read<AuthCubit>().signInWithGoogle(),
                            state: state,
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PhoneView extends StatelessWidget {
  final TextEditingController phoneController;
  final VoidCallback onSendOtp;
  final VoidCallback onGoogle;
  final AuthState state;

  const _PhoneView({
    required this.phoneController,
    required this.onSendOtp,
    required this.onGoogle,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isSendingOtp = state is AuthOtpInProgress;
    final isGoogleLoading = state is AuthLoading;
    final busy = isSendingOtp || isGoogleLoading;

    final quote = AppConstants.motivationalQuotes[
        DateTime.now().day % AppConstants.motivationalQuotes.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Center(child: const AppLogo(size: 92)),
        const SizedBox(height: 24),
        Text(
          'Welcome to ${AppConstants.appName}',
          textAlign: TextAlign.center,
          style: AppTextStyles.displayMedium
              .copyWith(color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 8),
        Text(
          'Learn smarter, achieve more',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 28),
        _QuoteCard(quote: quote),
        const Spacer(),
        Text('Sign in with your mobile number',
            style: AppTextStyles.titleMedium),
        const SizedBox(height: 12),
        _PhoneField(controller: phoneController, enabled: !busy),
        const SizedBox(height: 18),
        _PrimaryButton(
          label: 'Send OTP',
          isLoading: isSendingOtp,
          onPressed: busy ? null : onSendOtp,
        ),
        const SizedBox(height: 22),
        const _OrDivider(),
        const SizedBox(height: 22),
        _GoogleButton(
          isLoading: isGoogleLoading,
          onPressed: busy ? null : onGoogle,
        ),
        const Spacer(),
        const SizedBox(height: 16),
        Text(
          'By continuing you agree to our Terms of Service\nand Privacy Policy',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _OtpView extends StatelessWidget {
  final AuthState state;
  final int otpLength;
  final int resendSeconds;
  final ValueChanged<String> onOtpChanged;
  final ValueChanged<String> onOtpCompleted;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onChangeNumber;

  const _OtpView({
    required this.state,
    required this.otpLength,
    required this.resendSeconds,
    required this.onOtpChanged,
    required this.onOtpCompleted,
    required this.onVerify,
    required this.onResend,
    required this.onChangeNumber,
  });

  String get _phone {
    final s = state;
    if (s is AuthCodeSent) return s.phoneNumber;
    if (s is AuthOtpInProgress) return s.phoneNumber;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final isVerifying = state is AuthOtpInProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: isVerifying ? null : onChangeNumber,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.blueTint,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.sms_rounded,
              size: 34, color: AppColors.primaryBlue),
        ),
        const SizedBox(height: 24),
        Text('Verify your number', style: AppTextStyles.displayMedium),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: AppTextStyles.bodyMedium,
            children: [
              const TextSpan(text: 'Enter the 6-digit code sent to\n'),
              TextSpan(
                text: _phone,
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        OtpInputField(
          length: otpLength,
          enabled: !isVerifying,
          onChanged: onOtpChanged,
          onCompleted: onOtpCompleted,
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          label: 'Verify & Continue',
          isLoading: isVerifying,
          onPressed: isVerifying ? null : onVerify,
        ),
        const SizedBox(height: 24),
        Center(
          child: resendSeconds > 0
              ? Text(
                  'Resend OTP in ${resendSeconds}s',
                  style: AppTextStyles.labelMedium,
                )
              : TextButton(
                  onPressed: isVerifying ? null : onResend,
                  child: Text(
                    'Resend OTP',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.primaryBlue),
                  ),
                ),
        ),
        const Spacer(),
        Center(
          child: TextButton.icon(
            onPressed: isVerifying ? null : onChangeNumber,
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Change mobile number'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const _PhoneField({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('+91', style: AppTextStyles.titleMedium),
              ],
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.divider),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              style: AppTextStyles.titleMedium,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                counterText: '',
                hintText: 'Mobile number',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;

  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: AppColors.primaryBlue.withValues(alpha: 0.5),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: AppTextStyles.bodyMedium.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppColors.primaryBlue.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label, style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GoogleButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.g_mobiledata,
                      size: 28, color: AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR', style: AppTextStyles.labelMedium),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}
