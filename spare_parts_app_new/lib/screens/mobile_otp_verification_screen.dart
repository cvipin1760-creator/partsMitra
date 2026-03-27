import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class MobileOtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const MobileOtpVerificationScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _MobileOtpVerificationScreenState createState() => _MobileOtpVerificationScreenState();
}

class _MobileOtpVerificationScreenState extends State<MobileOtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showFeedback('OTP must be 6 digits', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.verifyMobileOtp(widget.phoneNumber, otp);

      if (success) {
        _showFeedback('Mobile number verified successfully!');
        Navigator.of(context).pop(true);
      } else {
        _showFeedback('Invalid OTP. Please try again.', isError: true);
      }
    } catch (e) {
      _showFeedback(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Mobile Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'An OTP has been sent to ${widget.phoneNumber}.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOtp,
                    child: const Text('Verify'),
                  ),
          ],
        ),
      ),
    );
  }
}
