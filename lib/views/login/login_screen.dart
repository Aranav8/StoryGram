import 'package:collabwrite/core/constants/assets.dart';
import 'package:collabwrite/views/home/home_screen.dart';
import 'package:flutter/material.dart';

import '../signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void login() {
    print('Login button pressed');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void signInWithGoogle() {
    print('Google sign-in button pressed');
  }

  void signInWithFacebook() {
    print('Facebook sign-in button pressed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Login to your account',
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "It's great to see you again.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF808080),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFields(
                    name: 'Email',
                    hintText: 'Enter your email address',
                    controller: _emailController,
                    validator: (value) {
                      if (value!.isEmpty ||
                          !value.contains('@') ||
                          !value.contains('.com')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFields(
                    name: 'Password',
                    hintText: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () {
                      print('Forgot password tapped');
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: 'Forgot your password?  ',
                        children: [
                          TextSpan(
                            text: 'Reset your password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Button(
                    name: 'Login',
                    textColor: Colors.white,
                    color: MaterialStateProperty.all<Color>(
                      const Color(0xFF1A1A1A),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logging in...')),
                        );
                        login();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(
                    color: Color(0xFFE6E6E6),
                    thickness: 1,
                  ),
                  const SizedBox(height: 10),
                  Button(
                    name: 'Sign Up with Google',
                    textColor: Colors.black,
                    color: MaterialStateProperty.all<Color>(Colors.white),
                    isOutlined: true,
                    imagePath: AppAssets.google,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Signing up with Google...')),
                      );
                      signInWithGoogle();
                    },
                  ),
                  const SizedBox(height: 10),
                  Button(
                    name: 'Sign Up with Facebook',
                    textColor: Colors.white,
                    color: MaterialStateProperty.all<Color>(
                        const Color(0xFF1877F2)),
                    imagePath: AppAssets.facebook,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Signing up with Facebook...')),
                      );
                      signInWithFacebook();
                    },
                  ),
                  const Spacer(),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            color: Color(0xFF808080),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  final MaterialStateProperty<Color?> color;
  final String name;
  final Color textColor;
  final String? imagePath;
  final bool isOutlined;
  final VoidCallback onPressed;

  const Button({
    super.key,
    required this.name,
    required this.textColor,
    required this.color,
    this.imagePath,
    this.isOutlined = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size>(const Size.fromHeight(55)),
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(color: textColor),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(imagePath!, width: 30, height: 30),
            if (imagePath != null) const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      );
    } else {
      return ElevatedButton(
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size>(const Size.fromHeight(55)),
          backgroundColor: color,
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(imagePath!, width: 30, height: 30),
            if (imagePath != null) const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      );
    }
  }
}

class TextFields extends StatefulWidget {
  final String name;
  final String hintText;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final IconButton? passwordVisibilityIcon;

  const TextFields({
    super.key,
    required this.name,
    required this.hintText,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.passwordVisibilityIcon,
  });

  @override
  _TextFieldsState createState() => _TextFieldsState();
}

class _TextFieldsState extends State<TextFields> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isValid = widget.validator?.call(widget.controller.text) == null;

    Color getBorderColor() {
      if (!_isFocused && widget.controller.text.isEmpty) {
        return Colors.grey;
      }
      return isValid ? Colors.green : Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.name,
          style: const TextStyle(
            fontFamily: 'GeneralSans',
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 60,
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText && _isObscure,
            cursorColor: const Color(0xFF808080),
            validator: widget.validator,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w300,
                color: Color(0xFF808080),
                fontFamily: 'GeneralSans',
              ),
              suffix: widget.obscureText
                  ? IconButton(
                      icon: _isObscure
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: getBorderColor(),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: getBorderColor(),
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
