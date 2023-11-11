import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/screen_direct.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:page_transition/page_transition.dart';

class LoginPageDesktop extends StatefulWidget {
  const LoginPageDesktop({super.key});

  @override
  State<LoginPageDesktop> createState() => _LoginPageDesktopState();
}

class _LoginPageDesktopState extends State<LoginPageDesktop> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? loginResult;
  String? _passwordError;
  String? _emailError;
  bool passToggle = true;

  void onLogin() async {
    setState(() {
      isLoading = true;
    });
    loginResult = await LoginFunction.login(email.text.trim(), password.text);
    bool isUser = loginResult == "USER";
    bool isAdmin = loginResult == "ADMIN";

    if (isUser) {
      //Update deviceToken
      // try {
      //   Map<String, dynamic> deviceToken = {
      //     'device_token': myToken,
      //   };
      //   await ProfileFunction.updateUserProfile(deviceToken);
      // } catch (e) {
      //   print(e);
      // }

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
              duration: const Duration(milliseconds: 500),
              child: const ScreenDirect(),
              type: PageTransitionType.fade),
          (route) => false);
    } else if (isAdmin) {
      //Update deviceToken
      // try {
      //   Map<String, dynamic> deviceToken = {
      //     'device_token': myToken,
      //   };
      //   await ProfileFunction.updateUserProfile(deviceToken);
      // } catch (e) {
      //   print(e);
      // }
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
              duration: const Duration(milliseconds: 500),
              child: const ScreenDirect(),
              type: PageTransitionType.fade),
          (route) => false);
    } else {
      if (loginResult ==
          'There is no user record corresponding to this identifier. The user may have been deleted.') {
        _emailError = 'User not found';
        loginResult = 'User not found';
      } else if (loginResult ==
          'The password is invalid or the user does not have a password.') {
        _passwordError = 'Wrong password';
        loginResult = 'Wrong password';
      } else {
        _emailError = loginResult;
        _passwordError = loginResult;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  sendResetPassword() async {
    if (email.text.isNotEmpty) {
      bool status = await LoginFunction.resetPassword(email.text);
      if (status) {
        // ignore: use_build_context_synchronously
        successMessage(
            title: "Sent!",
            desc: "Check your email!",
            duration: 5,
            context: context);
      } else {
        // ignore: use_build_context_synchronously
        errorMessage(
            title: "Something went wrong!",
            desc: "Make sure your email is correct",
            duration: 5,
            context: context);
      }
    }
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  var focusNode = FocusNode();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Scaffold(
            body: Center(
              child: Scaffold(
                appBar: AppBar(
                  leading: BackButton(
                    onPressed: () {
                      Routes().navigate("Home", context);
                    },
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onBackground,
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Routes().navigate("Register", context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor:
                            Theme.of(context).colorScheme.onBackground,
                        elevation: 0,
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                body: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 0),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text(
                                  'Please enter your details',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: email,
                                  onFieldSubmitted: (value) {
                                    _emailError = null;
                                    _passwordError = null;
                                    if (_formKey.currentState!.validate()) {
                                      onLogin();
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    String pattern = r'\w+@\w+\.\w+';
                                    RegExp regex = RegExp(pattern);
                                    if (!regex.hasMatch(value)) {
                                      return 'Invalid Email format';
                                    }
                                    // if (_emailError != null) {
                                    //   String err = _emailError!;
                                    //   _emailError = null;
                                    //   return err;
                                    // }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email),
                                    suffixIcon: loginResult != null
                                        ? _emailError == null
                                            ? const Icon(
                                                Icons.check,
                                              )
                                            : const Icon(
                                                Icons.close,
                                              )
                                        : null,
                                    suffixIconColor: _emailError == null
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: password,
                                  onFieldSubmitted: (value) {
                                    _emailError = null;
                                    _passwordError = null;
                                    if (_formKey.currentState!.validate()) {
                                      onLogin();
                                    }
                                  },
                                  obscureText: passToggle,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    // if (_passwordError != null) {
                                    //   String err = _passwordError!;
                                    //   _passwordError = null;
                                    //   return err;
                                    // }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: loginResult != null &&
                                            _emailError == null
                                        ? _passwordError == null
                                            ? const Icon(
                                                Icons.check,
                                              )
                                            : const Icon(
                                                Icons.close,
                                              )
                                        : null,
                                    suffixIconColor: _emailError == null &&
                                            _passwordError == null
                                        ? Colors.green
                                        : Colors.red,
                                    suffix: InkWell(
                                      onTap: () {
                                        setState(() {
                                          passToggle = !passToggle;
                                        });
                                      },
                                      child: Icon(passToggle
                                          ? Icons.visibility
                                          : Icons.visibility_off),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                loginResult == null
                                    ? Container()
                                    : Text(
                                        loginResult!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _emailError = null;
                                    _passwordError = null;
                                    if (_formKey.currentState!.validate()) {
                                      onLogin();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 50.0),
                                    backgroundColor:
                                        ccLoginButtonBGColor(context),
                                    foregroundColor:
                                        ccLoginButtonFGColor(context),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => RawKeyboardListener(
                                          focusNode: focusNode,
                                          onKey: (event) {
                                            if (event.isKeyPressed(
                                                LogicalKeyboardKey.enter)) {
                                              sendResetPassword();
                                            }
                                          },
                                          child: AlertDialog(
                                            title: const Text("Reset Password"),
                                            content: SizedBox(
                                              width: 500,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                      "Enter your email"),
                                                  TextField(
                                                    onSubmitted: (value) {
                                                      sendResetPassword();
                                                    },
                                                    controller: email,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton.icon(
                                                onPressed: sendResetPassword,
                                                icon: const Icon(Icons.send),
                                                label: const Text("Send"),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.lock_reset_outlined),
                                    label: const Text("Forgot Password?"),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: siteModel != null
                                ? siteModel!.siteAboutImage == ""
                                    ? const AssetImage(noImage) as ImageProvider
                                    : NetworkImage(siteModel!.siteAboutImage)
                                : const AssetImage(noImage),
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
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
}
