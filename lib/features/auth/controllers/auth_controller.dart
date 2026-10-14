import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../../../routes/app_routes.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final phoneController = TextEditingController(text: '1609157849');
  final passwordController = TextEditingController(text: '123456');
  final captchaController = TextEditingController();
  final inviteCodeController = TextEditingController();
  final smsCodeController = TextEditingController();
  
  final selectedCountryCode = '+880'.obs;
  final generatedCaptcha = ''.obs;
  final isLoading = false.obs;
  final isInviteCodeLocked = false.obs;

  // OTP State for Registration
  final isSendingOtp = false.obs;
  final otpCountdown = 0.obs;
  final isPhoneLocked = false.obs;
  Timer? _otpTimer;

  // Password Visibility Toggles
  final isPasswordVisible = false.obs;
  final isRegisterPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible.value = !isRegisterPasswordVisible.value;
  }

  // Observable user model
  final currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadCachedUser();
    refreshCaptcha();
    initInviteCode();
  }

  Future<void> _loadCachedUser() async {
    try {
      final cached = await TokenStorage.instance.getUser();
      if (cached != null && cached.isNotEmpty && currentUser.value == null) {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        currentUser.value = UserModel.fromJson(map);
      }
    } catch (_) {}
  }

  void initInviteCode() {
    String? code;

    // 1. Check Get.parameters
    if (Get.parameters.containsKey('id') && Get.parameters['id']!.trim().isNotEmpty) {
      code = Get.parameters['id']!.trim();
    } else if (Get.parameters.containsKey('code') && Get.parameters['code']!.trim().isNotEmpty) {
      code = Get.parameters['code']!.trim();
    }

    // 2. Check currentRoute e.g. /register/10203
    if (code == null || code.isEmpty) {
      final current = Get.currentRoute;
      final regMatch = RegExp(r'/register/([^/?#]+)').firstMatch(current);
      if (regMatch != null && regMatch.group(1) != null) {
        code = regMatch.group(1)!.trim();
      }
    }

    // 3. Fallback to default
    code ??= 'ADMIN001';

    inviteCodeController.text = code;
    isInviteCodeLocked.value = true;
  }

  void refreshCaptcha() {
    final rand = Random();
    generatedCaptcha.value = (1000 + rand.nextInt(9000)).toString();
  }

  void updateCountryCode(String code) {
    selectedCountryCode.value = code;
  }

  void setUser(UserModel user) {
    currentUser.value = user;
  }

  /// Normalize phone to 11 digits Bangladesh format (e.g. 01712345678)
  String getNormalizedPhone() {
    String phone = phoneController.text.trim();
    phone = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.length == 10 && phone.startsWith('1')) {
      phone = '0$phone';
    } else if (phone.length > 11) {
      phone = phone.substring(phone.length - 11);
    }
    return phone;
  }

  /// Send OTP to user's mobile number via API
  Future<void> sendOtp() async {
    final mobile = getNormalizedPhone();

    if (mobile.isEmpty || mobile.length < 11) {
      Get.snackbar(
        'Invalid Mobile Number',
        'Please enter a valid 11-digit mobile number first (e.g. 01712345678).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isSendingOtp.value = true;
      final response = await ApiClient.instance.post(
        ApiEndpoints.customerSendOtp,
        data: {'mobile': mobile},
      );

      // Lock the phone number field so user cannot edit it during registration
      isPhoneLocked.value = true;

      // Start 4-minute (240 seconds) cooldown timer
      otpCountdown.value = 240;
      _otpTimer?.cancel();
      _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (otpCountdown.value > 0) {
          otpCountdown.value--;
        } else {
          timer.cancel();
        }
      });

      final resData = response.data;
      final msg = (resData is Map && resData['message'] != null)
          ? resData['message'].toString()
          : 'Verification code sent to $mobile';

      Get.snackbar(
        'OTP Sent Successfully',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } on ApiException catch (e) {
      Get.snackbar(
        'Failed to Send OTP',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Network Error',
        'Could not reach server: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      );
    } finally {
      isSendingOtp.value = false;
    }
  }

  /// Real Customer Login (POST /customer/auth/login)
  Future<void> login() async {
    final mobile = getNormalizedPhone();
    final password = passwordController.text.trim();

    if (mobile.isEmpty || mobile.length < 11) {
      Get.snackbar(
        'Notice',
        'Please enter a valid 11-digit mobile number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }
    if (password.isEmpty) {
      Get.snackbar(
        'Notice',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await ApiClient.instance.post(
        ApiEndpoints.customerLogin,
        data: {
          'mobile': mobile,
          'password': password,
        },
      );

      final responseMap = (response.data is Map)
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      final authResponse = AuthResponseModel.fromJson(responseMap);

      if (authResponse.success || response.statusCode == 200) {
        final authData = authResponse.data;

        if (authData.accessToken.isNotEmpty) {
          await ApiClient.instance.setToken(authData.accessToken);
        }
        if (authData.refreshToken.isNotEmpty) {
          await TokenStorage.instance.saveRefreshToken(authData.refreshToken);
        }

        currentUser.value = authData.user;
        await TokenStorage.instance.saveUser(jsonEncode(authData.user.toJson()));

        Get.snackbar(
          'Login Successful',
          'Welcome back!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        Get.offAllNamed(AppRoutes.main);
      } else {
        final errorMsg = authResponse.message.isNotEmpty
            ? authResponse.message
            : 'Login failed. Please check your credentials.';
        Get.snackbar(
          'Login Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
        );
      }
    } on ApiException catch (e) {
      Get.snackbar(
        'Login Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Network Error',
        'Could not complete login: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Real Customer Registration (POST /customer/auth/register)
  Future<void> register() async {
    final mobile = getNormalizedPhone();
    final password = passwordController.text.trim();
    final otp = smsCodeController.text.trim();
    final referralCode = inviteCodeController.text.trim();

    if (mobile.isEmpty || mobile.length < 11) {
      Get.snackbar(
        'Invalid Mobile Number',
        'Please enter a valid 11-digit mobile number.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    if (otp.isEmpty) {
      Get.snackbar(
        'OTP Required',
        'Please enter the SMS verification code received on your phone.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.sms_failed_outlined, color: Colors.white),
      );
      return;
    }

    if (password.isEmpty || password.length < 6) {
      Get.snackbar(
        'Password Too Short',
        'Password must be at least 6 characters long.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.lock_clock_outlined, color: Colors.white),
      );
      return;
    }

    try {
      isLoading.value = true;

      // Customer Registration: POST /customer/auth/register (backend validates OTP directly)
      final registerPayload = <String, dynamic>{
        'mobile': mobile,
        'password': password,
        'otp': otp,
      };
      if (referralCode.isNotEmpty) {
        registerPayload['referralCode'] = referralCode;
      }

      final registerResponse = await ApiClient.instance.post(
        ApiEndpoints.customerRegister,
        data: registerPayload,
      );

      final responseMap = (registerResponse.data is Map)
          ? Map<String, dynamic>.from(registerResponse.data as Map)
          : <String, dynamic>{};
      final authResponse = AuthResponseModel.fromJson(responseMap);

      if (authResponse.success ||
          registerResponse.statusCode == 200 ||
          registerResponse.statusCode == 201) {
        final authData = authResponse.data;

        if (authData.accessToken.isNotEmpty) {
          await ApiClient.instance.setToken(authData.accessToken);
        }
        if (authData.refreshToken.isNotEmpty) {
          await TokenStorage.instance.saveRefreshToken(authData.refreshToken);
        }

        // Set UserModel from strongly-typed response
        currentUser.value = authData.user;
        await TokenStorage.instance.saveUser(jsonEncode(authData.user.toJson()));

        Get.snackbar(
          'Registration Successful',
          'Welcome to Projonmo! Your account has been registered.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          duration: const Duration(seconds: 3),
        );

        Get.offAllNamed(AppRoutes.main);
      } else {
        final errorMsg = authResponse.message.isNotEmpty
            ? authResponse.message
            : 'Registration failed. Please try again.';
        Get.snackbar(
          'Registration Failed',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } on ApiException catch (e) {
      String errorMessage = e.message;
      if (errorMessage.toLowerCase().contains('otp')) {
         errorMessage = 'OTP verification failed. Please check the code.';
      }
      Get.snackbar(
        'Registration Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not complete registration: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    currentUser.value = null;
    ApiClient.instance.clearToken();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
    super.onClose();
  }
}
