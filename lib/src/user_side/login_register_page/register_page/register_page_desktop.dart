import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/user_side/forum_page/ui/forum_page/forum_page.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_function.dart';

class RegisterPageDesktop extends StatefulWidget {
  const RegisterPageDesktop({super.key});

  @override
  State<RegisterPageDesktop> createState() => _RegisterPageDesktopState();
}

class _RegisterPageDesktopState extends State<RegisterPageDesktop> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController username = TextEditingController();
  String? registerResult;
  bool isLoading = false;
  bool passToggle = true;
  final _formKey = GlobalKey<FormState>();

  void onCreateAccount(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    registerResult = await RegisterFunction.createAccout(email.text,
        password.text, firstName.text, lastName.text, username.text);
    bool isAccountSuccessfullyCreated = registerResult == "true";

    if (isAccountSuccessfullyCreated) {
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ForumPage()),
          (route) => false);
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Neighboard Says..'),
            content: Text(registerResult!),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      // something went wrong
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    firstName.dispose();
    lastName.dispose();
    username.dispose();
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
                  title: const Text('NEIGHBOARD'),
                  actions: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        backgroundColor: ccRegisterButtonBGColor(context),
                        foregroundColor: ccRegisterButtonFGColor(context),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Register'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Routes().navigate("Login", context);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        foregroundColor: ccRegisterLoginButtonFGColor(context),
                      ),
                      child: const Text('Login'),
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
                                    'Register',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    'Get more features and priviliges by joining the La Aldea Community',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: firstName,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "First name is required";
                                      }
                                      final alpha = RegExp(r'^[a-zA-Z]+$');
                                      if (!alpha.hasMatch(value)) {
                                        return "Symbols and Numbers are not allowed.\nFor suffixes like 2nd or 3rd, use Roman Numeral letters";
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'First Name',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: lastName,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Last name is required";
                                      }
                                      final alpha = RegExp(r'^[a-zA-Z]+$');
                                      if (!alpha.hasMatch(value)) {
                                        return "Symbols and Numbers are not allowed.\nFor suffixes like 2nd or 3rd, use Roman Numeral letters";
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Last Name',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: email,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Email',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Email is required';
                                      }
                                      String pattern = r'\w+@\w+\.\w+';
                                      RegExp regex = RegExp(pattern);
                                      if (!regex.hasMatch(value)) {
                                        return 'Invalid Email format';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: username,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Username is required";
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Username',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: password,
                                    obscureText: passToggle,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: 'Password',
                                      //prefixIcon: const Icon(Icons.lock),
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Password is required";
                                      }
                                      String pattern =
                                          r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
                                      RegExp regex = RegExp(pattern);
                                      if (!regex.hasMatch(value)) {
                                        return 'Password must be at least 8 characters, \nInclude an uppercase letter and a number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        onCreateAccount(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 50.0),
                                      backgroundColor:
                                          ccRegisterButtonBGColor(context),
                                      foregroundColor:
                                          ccRegisterButtonFGColor(context),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    ),
                                    child: const Text(
                                      'REGISTER',
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
                        )),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(homeImage),
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
