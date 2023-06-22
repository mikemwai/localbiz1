// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_print, sized_box_for_whitespace
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/authentication.dart';
import 'reset_password.dart';
import 'signup.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  String _email =
      ''; // Provide an initial value to avoid LateInitializationError
  late String _password = '';
  bool _showError = false; // Variable to track authentication error state
  bool _isPasswordVisible = false; // Track password visibility
  Timer? _timer; // Timer to clear error message after a certain duration
  bool _isFingerprintSupported = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    _checkFingerprintSupport();
    Authentication.initializeFirebase();
    Authentication.checkSignedIn(context);
    super.initState();
  }

  Future<void> _checkFingerprintSupport() async {
    bool isSupported = false;
    try {
      isSupported = await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Fingerprint support check error: $e');
    }

    setState(() {
      _isFingerprintSupported = isSupported;
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the state is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
          centerTitle: true,
          //backgroundColor: Colors.black45,
          title: const Text('LocalBiz'),
        ),*/
      body: ListView(
        padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
        children: [
          Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              const Center(
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Add the error message widget conditionally
              if (_showError)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Invalid credentials. Please try again.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: "Enter your email address",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0))),
                  errorText: _email.isEmpty && _showError
                      ? 'Empty field not allowed'
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _email = value.trim();
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText:
                    !_isPasswordVisible, // Use obscureText based on visibility state
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  errorText: _password.isEmpty && _showError
                      ? 'Empty field not allowed'
                      : null,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible =
                            !_isPasswordVisible; // Toggle password visibility
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _password = value.trim();
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding:
                      const EdgeInsets.only(right: 15), // Add right margin here
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ResetPassword()));
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                //width: MediaQuery.of(context).size.width,
                width: 360,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    onPressed: () {
                      setState(() {
                        _showError = true;
                      });

                      // Start the timer to clear the error message after 3 seconds (adjust the duration as needed)
                      _timer
                          ?.cancel(); // Cancel the previous timer if it exists
                      _timer = Timer(const Duration(seconds: 3), () {
                        setState(() {
                          _showError = false;
                        });
                      });

                      Authentication.signin(
                        context,
                        _email,
                        _password,
                        () {
                          setState(() {
                            _showError = true;
                          });
                        },
                      );

                      if (_email.isEmpty || _password.isEmpty) {
                        return;
                      }
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 360,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Color.fromARGB(255, 253, 253,
                        253), // Set the desired background color here
                  ),
                  onPressed: () {
                    Authentication.signinWithGoogle(context: context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center the children horizontally
                    children: [
                      Container(
                        width: 25, // Set the desired width for the image
                        height: 25, // Set the desired height for the image
                        child: Image.asset(
                          'assets/google.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                          width: 10), // Add spacing between the image and text
                      const Text(
                        'Sign in with Google',
                        textAlign:
                            TextAlign.center, // Center the text horizontally
                        style: TextStyle(
                          //fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color.fromARGB(255, 9, 9, 9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text('Don\'t have an account?'),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Signup()));
                },
                child: const Text(
                  'Sign up Now',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _isFingerprintSupported
          ? FloatingActionButton(
              onPressed: () => _authenticateWithFingerprint(),
              child: Icon(FontAwesomeIcons.fingerprint),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _authenticateWithFingerprint() async {
    bool isAuthenticated = false;
    try {
      isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate with fingerprint to continue',
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print('Fingerprint authentication error: $e');
    }

    if (isAuthenticated) {
      Authentication.signinWithGoogle(context: context);
    }
  }
}
