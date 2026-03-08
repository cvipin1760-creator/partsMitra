// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import 'package:spare_parts_app/services/auth_exceptions.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final Map<String, dynamic>? registrationData;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.registrationData,
  });

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'OTP Verification',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: '6-Digit OTP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  if (value.length != 6) {
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isLoading = true);
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    try {
                      if (widget.registrationData != null) {
                        // This is for registration
                        final success = await authProvider.register(
                          widget.registrationData!['name'],
                          widget.registrationData!['email'],
                          widget.registrationData!['password'],
                          widget.registrationData!['role'],
                          widget.registrationData!['phone'] ?? '',
                          widget.registrationData!['address'] ?? '',
                          latitude: widget.registrationData!['latitude'],
                          longitude: widget.registrationData!['longitude'],
                          otp: _otpController.text,
                        );
                        if (success) {
                          _showFeedback('Registration successful! Please login.');
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      } else {
                        // Standalone verification (if needed)
                        final success = await authProvider.verifyOtp(
                          _otpController.text,
                        );
                        if (success) {
                          _showFeedback('OTP verified successfully!');
                          Navigator.of(context).pop(true);
                        } else {
                          _showFeedback('Invalid OTP', isError: true);
                        }
                      }
                    } catch (e) {
                      _showFeedback(e.toString(), isError: true);
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Verify'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final source = await authProvider.sendOtp(
                          widget.email,
                          widget.registrationData ?? {},
                        );
                        final via = source == 'server' ? 'server' : 'email';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('OTP resent via $via'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                child: const Text('Resend OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedback(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }
}
