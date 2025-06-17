
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlutterLogin(
      theme: myLoginTheme,
      onLogin: (LoginData data) {
        ref.read(authServiceProvider.notifier).signIn(data.name, data.password);
        return null;
      },
      onRecoverPassword: (_) => null,
    );
  }
}

LoginTheme myLoginTheme = LoginTheme(
  // Page Background
    pageColorLight: Colors.lightBlue.shade100,
    // For light mode
    pageColorDark: Colors.blueGrey.shade900,
    // For dark mode (if your app supports it)

    // Header (Logo and Title)
    primaryColor: Colors.teal,
    // Accent color for buttons, input field borders when focused
    accentColor: Colors.orangeAccent,
    // Used for some highlights, can be same as primary
    errorColor: Colors.redAccent,

    // Title
    titleStyle: const TextStyle(
      color: Colors.deepPurple,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    ),

    // Body Text (like "Forgot Password?")
    bodyStyle: TextStyle(
      color: Colors.grey.shade800,
      fontSize: 14,
    ),

    // TextField Theme
    textFieldStyle: TextStyle(
      color: Colors.black87,
      fontSize: 16,
      shadows: [
        Shadow(color: Colors.grey.withOpacity(0.3),
            blurRadius: 2,
            offset: const Offset(1, 1))
      ],
    ),
    inputTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.8),
      contentPadding: const EdgeInsets.all(15),
      // Border when the input field is not focused
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      // Border when the input field is focused
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.teal, width: 2),
      ),
      // Error border
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      // Label style
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 15),
      // Hint style
      hintStyle: TextStyle(color: Colors.grey.shade500),
      // Error style
      errorStyle: const TextStyle(
          color: Colors.redAccent, fontWeight: FontWeight.bold),
    ),

    // Button Theme
    buttonTheme: LoginButtonTheme(
      splashColor: Colors.orange.shade200,
      backgroundColor: Colors.teal,
      highlightColor: Colors.teal.shade700,
      elevation: 5.0,
      highlightElevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      // You can also define specific text styles for buttons
      // mainButtonStyle, providerButtonStyle, textButtonStyle
    ),

    // Card Theme (the container for the form)
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.9),
      elevation: 8.0,
      margin: const EdgeInsets.all(20.0),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
    )

);

