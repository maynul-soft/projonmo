import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_glass.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initInviteCode();
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: AppGlass.flexibleSpace,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: const Text(
          AppStrings.registerTitle,
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Form Card containing all context centered
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App Logo icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 14),

                        // Welcome Header inside Form Card (Center aligned)
                        const Text(
                          'Create Your Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Welcome! Join Projonmo investment and start earning daily commission.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Phone Input (Bangladesh +880 only)
                        Row(
                          children: [
                            Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🇧🇩 ', style: TextStyle(fontSize: 16)),
                                  Text(
                                    '+880',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Obx(() {
                                final isLocked = controller.isPhoneLocked.value;
                                return TextField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  readOnly: isLocked,
                                  enabled: !isLocked,
                                  style: TextStyle(
                                    color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                                    fontWeight: isLocked ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: AppStrings.phonePlaceholder,
                                    filled: isLocked,
                                    fillColor: isLocked ? AppColors.surfaceMuted : Colors.white,
                                    suffixIcon: isLocked
                                        ? const Tooltip(
                                            message: 'Mobile number locked after sending OTP',
                                            child: Icon(Icons.lock_rounded, size: 18, color: AppColors.primary),
                                          )
                                        : null,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // SMS Verification Code with integrated suffix Send Button (Overflow-safe)
                        TextField(
                          controller: controller.smsCodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.sms_outlined, color: AppColors.primary),
                            hintText: AppStrings.smsCodePlaceholder,
                            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Obx(() {
                                final isSending = controller.isSendingOtp.value;
                                final countdown = controller.otpCountdown.value;
                                final canSend = !isSending && countdown == 0;

                                return MouseRegion(
                                  cursor: canSend ? SystemMouseCursors.click : SystemMouseCursors.basic,
                                  child: GestureDetector(
                                    onTap: canSend ? controller.sendOtp : null,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: canSend ? AppColors.primary : AppColors.surfaceMuted,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: canSend ? AppColors.primary : AppColors.border,
                                        ),
                                      ),
                                      child: isSending
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              countdown > 0 ? '${countdown}s' : AppStrings.sendSms,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: canSend ? Colors.white : AppColors.textMuted,
                                              ),
                                            ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Input
                        Obx(() => TextField(
                          controller: controller.passwordController,
                          obscureText: !controller.isRegisterPasswordVisible.value,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                            hintText: AppStrings.passwordPlaceholder,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isRegisterPasswordVisible.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                              onPressed: controller.toggleRegisterPasswordVisibility,
                            ),
                          ),
                        )),
                        const SizedBox(height: 16),

                        // Invitation Code Input (Non-editable as requested: "reedem code editable thakbe na")
                        TextField(
                          controller: controller.inviteCodeController,
                            readOnly: true,
                            enableInteractiveSelection: false,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.card_giftcard_rounded, color: AppColors.primary),
                              hintText: AppStrings.invitationCodePlaceholder,
                              filled: true,
                              fillColor: AppColors.surfaceMuted,
                              suffixIcon: const Tooltip(
                                message: 'Invitation referral code locked',
                                child: Icon(Icons.lock_rounded, size: 18, color: AppColors.primary),
                              ),
                              helperText: 'Inviter referral code applied.',
                              helperStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Sign Up Submit Button
                        Obx(() {
                          final isLoading = controller.isLoading.value;
                          return ElevatedButton(
                            onPressed: isLoading ? null : controller.register,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.82),
                              disabledForegroundColor: Colors.white,
                              elevation: isLoading ? 0 : 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isLoading
                                  ? const Row(
                                      key: ValueKey('reg_loading'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Registering...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Text(
                                      AppStrings.signUpBtn,
                                      key: ValueKey('reg_text'),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),

                        // Back to Login Link inside Card
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                            ),
                            TextButton(
                              onPressed: () => Get.offNamed(AppRoutes.login),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
