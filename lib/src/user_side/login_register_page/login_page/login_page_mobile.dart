import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/user_side/login_register_page/login_page/login_function.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LoginPageMobile extends StatefulWidget {
  const LoginPageMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<LoginPageMobile> createState() => _LoginPageMobileState();
}

class _LoginPageMobileState extends State<LoginPageMobile> {
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
    bool isLoginSuccessful = loginResult == "true";

    if (isLoginSuccessful) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ForumPage(),
        ),
      );
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
                  automaticallyImplyLeading: true,
                  actions: [
                    OutlinedButton(
                      onPressed: () {
                        Routes().navigate("Register", context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        foregroundColor: ccLoginRegisterButtonFGColor(context),
                      ),
                      child: const Text('Register'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: ccLoginButtonBGColor(context),
                        foregroundColor: ccLoginButtonFGColor(context),
                      ),
                      icon: const Icon(Icons.person_2_outlined),
                      label: const Text('Login'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                body: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(homeImage),
                                fit: BoxFit.cover,
                                opacity: 100)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30.w, vertical: 0),
                        child: Center(
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
                                      : Center(
                                          child: Text(
                                            loginResult!,
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _emailError = null;
                                        _passwordError = null;
                                      });
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
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    ),
                                    child: const Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
