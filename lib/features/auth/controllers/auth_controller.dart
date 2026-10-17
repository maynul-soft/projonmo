import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/network.dart';
import '../../../routes/app_routes.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../../profile/controllers/profile_controller.dart';

class AuthController extends GetxController {
  // Removed default credentials so it doesn't show automatically
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
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
    String raw = phoneController.text.trim();

    // If developer/user pasted full JSON or key-value like {"mobile":"01609157849", "password":"123456"}
    if (raw.contains('mobile') || raw.contains('phone')) {
      try {
        final cleanJson = raw.startsWith('{') ? raw : '{$raw}';
        final decoded = jsonDecode(cleanJson);
        if (decoded is Map) {
          if (decoded['mobile'] != null || decoded['phone'] != null) {
            raw = (decoded['mobile'] ?? decoded['phone']).toString();
            phoneController.text = raw;
          }
          if (decoded['password'] != null) {
            passwordController.text = decoded['password'].toString();
          }
        }
      } catch (_) {
        final mobileMatch = RegExp(r'mobile\D+(\d+)').firstMatch(raw);
        if (mobileMatch != null) {
          raw = mobileMatch.group(1)!;
          phoneController.text = raw;
        }
        final passMatch = RegExp(r'password\D+([^\s,"}]+)').firstMatch(raw);
        if (passMatch != null) {
          passwordController.text = passMatch.group(1)!;
        }
      }
    }

    // Strip all non-digit characters
    String phone = raw.replaceAll(RegExp(r'\D'), '');

    // Strip BD country code prefixes: 880 or 88
    if (phone.startsWith('880')) {
      phone = phone.substring(3);
    } else if (phone.startsWith('88')) {
      phone = phone.substring(2);
    }

    // If user entered 10 digits starting with 1 (e.g. 1609157849), prepend '0'
    if (phone.length == 10 && phone.startsWith('1')) {
      phone = '0$phone';
    }

    // If longer than 11 digits, extract the last 11 digits
    if (phone.length > 11) {
      phone = phone.substring(phone.length - 11);
    }

    return phone;
  }

  /// Send OTP to user's mobile number via API
  Future<void> sendOtp() async {
    if (isSendingOtp.value) return;
    Get.closeAllSnackbars();

    final mobile = getNormalizedPhone();

    if (mobile.isEmpty || mobile.length != 11 || !mobile.startsWith('01')) {
      Get.snackbar(
        'Invalid Mobile Number',
        'Please enter a valid 11-digit mobile number (e.g. 01712345678).',
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

      Get.closeAllSnackbars();
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
    // Prevent duplicate calls
    if (isLoading.value) return;

    // Immediately clear all existing snackbars and hide keyboard
    Get.closeAllSnackbars();
    FocusManager.instance.primaryFocus?.unfocus();

    final mobile = getNormalizedPhone();
    final password = passwordController.text.trim();

    if (mobile.isEmpty || mobile.length != 11 || !mobile.startsWith('01')) {
      Get.snackbar(
        'Invalid Mobile Number',
        'Please enter a valid 11-digit mobile number (e.g. 017XXXXXXXX)',
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
    if (password.isEmpty) {
      Get.snackbar(
        'Password Required',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.lock_outline_rounded, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('[AuthController] Attempting login: mobile="$mobile", passwordLength=${password.length}');

      final response = await ApiClient.instance.post(
        ApiEndpoints.customerLogin,
        data: {
          'mobile': mobile,
          'password': password,
        },
      );

      dynamic resData = response.data;
      if (resData is String) {
        try {
          resData = jsonDecode(resData);
        } catch (_) {}
      }

      final responseMap = (resData is Map)
          ? Map<String, dynamic>.from(resData as Map)
          : <String, dynamic>{};
      final authResponse = AuthResponseModel.fromJson(responseMap);

      if (authResponse.success || response.statusCode == 200) {
        final authData = authResponse.data;

        if (authData.accessToken.isNotEmpty) {
          await ApiClient.instance.setToken(authData.accessToken);
        } else {
          throw const ApiException(message: 'Login failed: No access token received from server.');
        }

        if (authData.refreshToken.isNotEmpty) {
          await TokenStorage.instance.saveRefreshToken(authData.refreshToken);
        }

        currentUser.value = authData.user;
        await TokenStorage.instance.saveUser(jsonEncode(authData.user.toJson()));

        // Also fetch profile immediately to populate ProfileController
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchCustomerProfile();
        }

        Get.closeAllSnackbars();
        Get.snackbar(
          'Login Successful',
          'Welcome back!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
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
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } on ApiException catch (e) {
      debugPrint('[AuthController] Login ApiException: ${e.message} (status: ${e.statusCode})');
      Get.snackbar(
        'Login Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    } catch (e) {
      debugPrint('[AuthController] Login General Exception: $e');
      Get.snackbar(
        'Network Error',
        'Could not complete login: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Real Customer Registration (POST /customer/auth/register)
  Future<void> register() async {
    if (isLoading.value) return;

    Get.closeAllSnackbars();
    FocusManager.instance.primaryFocus?.unfocus();

    final mobile = getNormalizedPhone();
    final password = passwordController.text.trim();
    final otp = smsCodeController.text.trim();
    final referralCode = inviteCodeController.text.trim();

    if (mobile.isEmpty || mobile.length != 11 || !mobile.startsWith('01')) {
      Get.snackbar(
        'Invalid Mobile Number',
        'Please enter a valid 11-digit mobile number (e.g. 017XXXXXXXX).',
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

      dynamic resData = registerResponse.data;
      if (resData is String) {
        try {
          resData = jsonDecode(resData);
        } catch (_) {}
      }

      final responseMap = (resData is Map)
          ? Map<String, dynamic>.from(resData as Map)
          : <String, dynamic>{};
      final authResponse = AuthResponseModel.fromJson(responseMap);

      if (authResponse.success ||
          registerResponse.statusCode == 200 ||
          registerResponse.statusCode == 201) {
        final authData = authResponse.data;

        if (authData.accessToken.isNotEmpty) {
          await ApiClient.instance.setToken(authData.accessToken);
        } else {
          throw const ApiException(message: 'Registration failed: No access token received from server.');
        }
        if (authData.refreshToken.isNotEmpty) {
          await TokenStorage.instance.saveRefreshToken(authData.refreshToken);
        }

        // Set UserModel from strongly-typed response
        currentUser.value = authData.user;
        await TokenStorage.instance.saveUser(jsonEncode(authData.user.toJson()));

        Get.closeAllSnackbars();
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
