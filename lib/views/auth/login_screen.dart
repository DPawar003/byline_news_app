import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../core/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _switchTab(bool isSignUp) {
    if (_isSignUp == isSignUp) return;
    final authVM = context.read<AuthViewModel>();
    authVM.clearErrorMessage();
    setState(() {
      _isSignUp = isSignUp;
      _autovalidateMode = AutovalidateMode.disabled;
      _confirmPasswordController.clear();
      _acceptedTerms = false;
      _showTermsError = false;
      _formKey.currentState?.reset();
    });
  }

  void _submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      if (_isSignUp && !_acceptedTerms) {
        _showTermsError = true;
      } else {
        _showTermsError = false;
      }
    });

    if (!_formKey.currentState!.validate()) return;
    if (_isSignUp && !_acceptedTerms) return;

    final authVM = context.read<AuthViewModel>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUp) {
      final name = _displayNameController.text.trim();
      await authVM.signUp(email, password, name);
    } else {
      await authVM.signIn(email, password);
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        bool isResetting = false;
        String? dialogError;

        return StatefulBuilder(
          builder: (dialogStateContext, setDialogState) {
            return AlertDialog(
              title: const Text('Reset Password'),
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your email address and we will send you instructions to reset your password.',
                      style: AppTypography.bodyMedium,
                    ),
                    AppSpacing.vMd,
                    if (dialogError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          dialogError!,
                          style: AppTypography.caption.copyWith(color: Colors.red),
                        ),
                      ),
                    ],
                    AppTextField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      autofocus: true,
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter your email address';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isResetting ? null : () => Navigator.of(dialogCtx).pop(),
                  child: const Text('CANCEL'),
                ),
                AppButton(
                  label: 'SEND LINK',
                  width: 120,
                  height: 42,
                  isLoading: isResetting,
                  onPressed: () async {
                    if (!dialogFormKey.currentState!.validate()) return;
                    setDialogState(() {
                      isResetting = true;
                      dialogError = null;
                    });

                    final email = resetEmailController.text.trim();
                    final success = await authVM.sendPasswordResetEmail(email);

                    if (dialogCtx.mounted) {
                      if (success) {
                        Navigator.of(dialogCtx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Password reset email sent to $email. Please check your inbox.'),
                            backgroundColor: Colors.blue.shade800,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      } else {
                        setDialogState(() {
                          isResetting = false;
                          dialogError = authVM.errorMessage ?? 'Failed to send reset email.';
                        });
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 8) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    return strength;
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.25) return Colors.red;
    if (strength <= 0.5) return Colors.orange;
    if (strength <= 0.75) return Colors.yellow.shade700;
    return Colors.green;
  }

  String _getStrengthText(double strength) {
    if (strength <= 0.25) return 'Weak';
    if (strength <= 0.5) return 'Fair';
    if (strength <= 0.75) return 'Good';
    return 'Strong';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final passStrength = _calculatePasswordStrength(_passwordController.text);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              autovalidateMode: _autovalidateMode,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Byline',
                    style: AppTypography.displayLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vXxs,
                  Text(
                    'Editorial News & Global Dispatch',
                    style: AppTypography.labelSmall.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.vXl,

                  // Tab switch: Sign In vs Create Account
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => _switchTab(false),
                          style: TextButton.styleFrom(
                            foregroundColor: !_isSignUp ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Sign In',
                                style: AppTypography.appButton.copyWith(
                                  fontWeight: !_isSignUp ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              AppSpacing.vXxs,
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 2,
                                color: !_isSignUp ? theme.colorScheme.secondary : Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => _switchTab(true),
                          style: TextButton.styleFrom(
                            foregroundColor: _isSignUp ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Create Account',
                                style: AppTypography.appButton.copyWith(
                                  fontWeight: _isSignUp ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              AppSpacing.vXxs,
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 2,
                                color: _isSignUp ? theme.colorScheme.secondary : Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vLg,

                  // Backend error alert box
                  if (authVM.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          AppSpacing.hSm,
                          Expanded(
                            child: Text(
                              authVM.errorMessage!,
                              style: AppTypography.bodyMedium.copyWith(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.vMd,
                  ],

                  // Display Name (Sign Up only)
                  if (_isSignUp) ...[
                    AppTextField(
                      controller: _displayNameController,
                      textInputAction: TextInputAction.next,
                      labelText: 'Full Name / Display Name',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (val.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(val.trim())) {
                          return 'Name can only contain letters, spaces, and hyphens';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.vMd,
                  ],

                  // Email Address
                  AppTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(val.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.vMd,

                  // Password
                  AppTextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: _isSignUp ? TextInputAction.next : TextInputAction.done,
                    onChanged: (_) {
                      if (_isSignUp) setState(() {});
                    },
                    onFieldSubmitted: (_) {
                      if (!_isSignUp) _submit();
                    },
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (_isSignUp) {
                        if (val.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        if (!RegExp(r'(?=.*[A-Z])').hasMatch(val)) {
                          return 'Must contain at least 1 uppercase letter';
                        }
                        if (!RegExp(r'(?=.*[0-9])').hasMatch(val)) {
                          return 'Must contain at least 1 digit';
                        }
                      } else {
                        if (val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                      }
                      return null;
                    },
                  ),

                  // Password Strength Meter (Sign Up only)
                  if (_isSignUp && _passwordController.text.isNotEmpty) ...[
                    AppSpacing.vXs,
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: passStrength,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor(passStrength)),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        AppSpacing.hSm,
                        Text(
                          _getStrengthText(passStrength),
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _getStrengthColor(passStrength),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Confirm Password (Sign Up only)
                  if (_isSignUp) ...[
                    AppSpacing.vMd,
                    AppTextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_reset_outlined, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (val != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    AppSpacing.vMd,

                    // Terms & Conditions checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _acceptedTerms,
                            activeColor: theme.colorScheme.primary,
                            onChanged: (val) {
                              setState(() {
                                _acceptedTerms = val ?? false;
                                if (_acceptedTerms) _showTermsError = false;
                              });
                            },
                          ),
                        ),
                        AppSpacing.hXs,
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptedTerms = !_acceptedTerms;
                                if (_acceptedTerms) _showTermsError = false;
                              });
                            },
                            child: Text(
                              'I agree to the Terms of Service and Privacy Policy.',
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_showTermsError) ...[
                      AppSpacing.vXxs,
                      Padding(
                        padding: const EdgeInsets.only(left: 32),
                        child: Text(
                          'You must accept the terms to create an account',
                          style: AppTypography.caption.copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ],

                  // Forgot Password Link (Sign In only)
                  if (!_isSignUp) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authVM.isLoading ? null : () => _showForgotPasswordDialog(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: AppTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],

                  AppSpacing.vLg,

                  // Submit Button
                  AppButton(
                    label: _isSignUp ? 'CREATE ACCOUNT' : 'SIGN IN',
                    isLoading: authVM.isLoading,
                    onPressed: _submit,
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
