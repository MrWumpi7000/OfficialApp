import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  int currentStep = 0; // 0=email, 1=code, 2=new password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String code = "";
  String? errorMessage;
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Field-specific errors
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? codeError;

  // Email validation regex
  bool get _isValidEmail {
    final email = _emailController.text.trim();
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  bool get _isValidPassword {
    return _passwordController.text.trim().length >= 6;
  }

  bool get _passwordsMatch {
    return _passwordController.text == _confirmPasswordController.text;
  }

  void _validateEmailField() {
    setState(() {
      emailError = null;
      final emailText = _emailController.text.trim();
      if (emailText.isEmpty) {
        emailError = "Email cannot be empty.";
      } else if (!_isValidEmail) {
        emailError = "Please enter a valid email address.";
      }
    });
  }

  void _validatePasswordFields() {
    setState(() {
      passwordError = null;
      confirmPasswordError = null;
      if (_passwordController.text.trim().isEmpty) {
        passwordError = "Password cannot be empty.";
      } else if (!_isValidPassword) {
        passwordError = "Password must be at least 6 characters.";
      }

      if (_confirmPasswordController.text.isNotEmpty && !_passwordsMatch) {
        confirmPasswordError = "Passwords do not match.";
      }
    });
  }

  void _validateCodeField() {
    setState(() {
      codeError = null;
      if (code.isEmpty) {
        codeError = "Enter the code you received via email.";
      } else if (code.length != 6) {
        codeError = "Code must be 6 digits.";
      }
    });
  }

  // Step 1: Send reset code to email
  Future<void> sendResetCode() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    _validateEmailField();
    if (emailError != null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      bool sent = await AuthService().sendResetCode(_emailController.text.trim());
      if (sent) {
        setState(() {
          currentStep = 1;
        });
      } else {
        setState(() {
          errorMessage = "Failed to send reset code. Please check your email.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Step 2: Validate code
  Future<void> validateCode() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    _validateCodeField();
    if (codeError != null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      bool valid = await AuthService().verifyResetCode(_emailController.text.trim(), code);
      if (valid) {
        setState(() {
          currentStep = 2;
        });
      } else {
        setState(() {
          errorMessage = "Invalid code. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Step 3: Reset password
  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    _validatePasswordFields();
    if (passwordError != null || confirmPasswordError != null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      bool reset = await AuthService().resetPassword(
        _emailController.text.trim(),
        code,
        _passwordController.text.trim(),
      );
      if (reset) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        setState(() {
          errorMessage = "Failed to reset password. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildImageHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: TopCurveClipper(),
          child: Container(
            height: 260,
            color: Color(0xFF6246EA),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(80),
                border: Border.all(color: Color(0xFF6246EA), width: 5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/resetpassword.jpg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 280,
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        _buildTitle("Reset password", "Please enter your email address to reset your password."),
        SizedBox(
          width: 340,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              _validateEmailField();
              setState(() {
                errorMessage = null;
              });
            },
            onEditingComplete: _validateEmailField,
            decoration: InputDecoration(
              hintText: "Email address*",
              errorText: emailError,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
              fillColor: const Color.fromARGB(255, 243, 243, 243),
              filled: true,
              suffixIcon: (_emailController.text.isNotEmpty && emailError == null)
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : (_emailController.text.isNotEmpty && emailError != null)
                      ? Icon(Icons.error, color: Colors.red)
                      : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      children: [
        _buildTitle("Enter verification code", "Please enter the code sent to your email address."),
        SizedBox(
          width: 300,
          height: 60,
          child: SixDigitCodeInput(
            onChanged: (v) {
              setState(() {
                code = v;
                errorMessage = null;
                _validateCodeField();
              });
            },
          ),
        ),
        if (codeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              codeError!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 15,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        _buildTitle("Set new password", "Enter your new password and confirm."),
        SizedBox(
          width: 340,
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            onChanged: (_) {
              _validatePasswordFields();
              setState(() {
                errorMessage = null;
              });
            },
            decoration: InputDecoration(
              hintText: "Password*",
              errorText: passwordError,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
              fillColor: const Color.fromARGB(255, 243, 243, 243),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 340,
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            onChanged: (_) {
              _validatePasswordFields();
              setState(() {
                errorMessage = null;
              });
            },
            decoration: InputDecoration(
              hintText: "Confirm Password*",
              errorText: confirmPasswordError,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide.none,
              ),
              fillColor: const Color.fromARGB(255, 243, 243, 243),
              filled: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildCodeStep();
      case 2:
        return _buildPasswordStep();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons() {
    String nextLabel;
    VoidCallback? nextAction;
    bool enableNext = false;

    if (currentStep == 0) {
      nextLabel = "Send";
      enableNext = _isValidEmail && !isLoading;
      nextAction = enableNext ? sendResetCode : null;
    } else if (currentStep == 1) {
      nextLabel = "Next";
      enableNext = code.length == 6 && !isLoading;
      nextAction = enableNext ? validateCode : null;
    } else if (currentStep == 2) {
      nextLabel = "Reset";
      enableNext = _isValidPassword && _passwordsMatch && !isLoading;
      nextAction = enableNext ? resetPassword : null;
    } else {
      nextLabel = "Next";
      nextAction = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0, left: 16, right: 16),
      child: SizedBox(
        width: 340,
        child: ElevatedButton(
          onPressed: enableNext ? nextAction : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6246EA),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  nextLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildImageHeader(),
          const SizedBox(height: 34),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildStepContent(),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }
}

// SixDigitCodeInput as in your original code (unchanged)
class SixDigitCodeInput extends StatefulWidget {
  final void Function(String)? onChanged;

  const SixDigitCodeInput({Key? key, this.onChanged}) : super(key: key);

  @override
  State<SixDigitCodeInput> createState() => _SixDigitCodeInputState();
}

class _SixDigitCodeInputState extends State<SixDigitCodeInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildCodeFields(String text) {
    List<Widget> fields = [];
    for (int i = 0; i < 6; i++) {
      final digit = (i < text.length) ? text[i] : '';
      fields.add(
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                digit,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ],
          ),
        ),
      );
      if (i < 5) fields.add(const SizedBox(width: 6));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: fields,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: false,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(color: Colors.transparent),
            cursorColor: Colors.transparent,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: "",
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (value) {
              setState(() {});
              if (widget.onChanged != null) widget.onChanged!(value);
            },
          ),
          IgnorePointer(
            ignoring: true,
            child: _buildCodeFields(_controller.text),
          ),
        ],
      ),
    );
  }
}

// TopCurveClipper as in your original code
class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}