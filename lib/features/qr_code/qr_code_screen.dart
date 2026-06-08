import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:byxex_match/core/session/session_state.dart';
import 'package:byxex_match/core/theme/app_colors.dart';
import 'package:byxex_match/core/widgets/screen_header.dart';

// Valid club QR pattern: byxex_club_<digits>
final RegExp _validQrPattern = RegExp(r'^byxex_club_\d+$');

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  bool _permissionGranted = false;
  bool _scanned = false;
  bool _invalidShown = false;
  Timer? _invalidTimer;

  @override
  void initState() {
    super.initState();
    if (SessionState.cameraPermissionAsked) {
      _permissionGranted = true;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPermissionDialog();
    });
  }

  @override
  void dispose() {
    _invalidTimer?.cancel();
    super.dispose();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '"N1 CyberForge" is requesting access to your camera',
                style: TextStyle(
                  fontFamily: 'BlackHanSans',
                  fontSize: 16,
                  color: Color(0xFF1A1A1A),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The app needs access to your camera to scan QR codes in the computer club — to activate a gaming station, enter the club, and add friends using codes.',
                style: TextStyle(
                  fontFamily: 'BlackHanSans',
                  fontSize: 13,
                  color: Color(0xFF6E6E73),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ByxexButton(
                  label: 'Allow',
                  onTap: () {
                    SessionState.cameraPermissionAsked = true;
                    Navigator.of(ctx).pop();
                    setState(() => _permissionGranted = true);
                  },
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  SessionState.cameraPermissionAsked = true;
                  Navigator.of(ctx).pop();
                  setState(() => _permissionGranted = false);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Don't Allow",
                    style: TextStyle(
                      fontFamily: 'BlackHanSans',
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue ?? '';
    if (value.isEmpty) return;

    if (_validQrPattern.hasMatch(value)) {
      SessionState.qrVerified = true;
      setState(() => _scanned = true);
    } else {
      if (_invalidShown) return;
      setState(() => _invalidShown = true);
      _invalidTimer?.cancel();
      _invalidTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _invalidShown = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ByxexBackground(
        child: SafeArea(
          child: Column(
            children: [
              const ByxexHeader(title: 'QR-CODE'),
              const SizedBox(height: 36),
              // Square scanning frame — green border, rounded
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.accentGreen,
                        width: 3,
                      ),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _permissionGranted && !_scanned
                        ? MobileScanner(onDetect: _onDetect)
                        : const SizedBox.shrink(),
                  ).animate().fadeIn(duration: 400.ms),
                ),
              ),
              const Spacer(),
              // Invalid QR feedback — shows for ~2s, lets user keep scanning
              if (_invalidShown && !_scanned)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16)
                      .copyWith(bottom: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: const Text(
                      'Invalid QR code.\nPlease scan a Byxex club code.',
                      style: TextStyle(
                        fontFamily: 'BlackHanSans',
                        fontSize: 15,
                        color: Color(0xFFB00020),
                        height: 1.3,
                      ),
                    ),
                  ).animate().fadeIn(duration: 200.ms),
                ),
              // Inline success card — appears after a valid scan
              if (_scanned)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16)
                      .copyWith(bottom: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Your PC has been activated.\nEnjoy the game!',
                          style: TextStyle(
                            fontFamily: 'BlackHanSans',
                            fontSize: 16,
                            color: Color(0xFF1A1A1A),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ByxexButton(
                            label: 'Ok',
                            onTap: () {
                              context.pushReplacement('/pc-control');
                            },
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 250.ms).slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 250.ms,
                        curve: Curves.easeOut,
                      ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: ByxexButton(
                  label: 'BACK',
                  onTap: () => context.pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
