import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/hoa_model.dart';
import 'package:neighboard/routes/routes.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/multi_factor_auth.dart';
import 'package:neighboard/src/user_side/login_register_page/register_page/register_function.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';
import 'package:responsive_builder/responsive_builder.dart';

class RegisterPageMobile extends StatefulWidget {
  const RegisterPageMobile({super.key, required this.deviceScreenType});

  final DeviceScreenType deviceScreenType;

  @override
  State<RegisterPageMobile> createState() => _RegisterPageMobileState();
}

class _RegisterPageMobileState extends State<RegisterPageMobile> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confPassword = TextEditingController();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController suffix = TextEditingController();
  final TextEditingController tcBlock = TextEditingController();
  final TextEditingController tcLot = TextEditingController();
  final TextEditingController tcCNo = TextEditingController();
  String street = "";
  String gender = "";
  bool isLoading = false;
  bool passToggle = true;
  String? registerResult;

  List<HOAModel> hoaModels = [];
  getHOAList() async {
    hoaModels = await SiteSettingsFunction.getHOA() ?? [];
    setState(() {
      isLoading = false;
    });
  }

  bool isVerified = false;

  void onCreateAccount(BuildContext context) async {
    if (gender.isEmpty) {
      errorMessage(
        title: "Gender",
        desc: "Choose Gender",
        context: context,
        duration: 5,
      );
      return;
    }
    final result = hoaModels
        .where((element) =>
            element.firstName
                .toLowerCase()
                .contains(firstName.text.toLowerCase()) &&
            element.lastName
                .toLowerCase()
                .contains(lastName.text.toLowerCase()) &&
            element.suffix.toLowerCase().contains(suffix.text.toLowerCase()) &&
            element.street.toLowerCase().contains(street.toLowerCase()) &&
            element.isRegistered == false)
        .toList();

    if (result.isEmpty) {
      infoMessage(
        title: "Neighboard Says..",
        desc: "Only HOA residents can register",
        context: context,
        duration: 5,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });
    bool isUsernameExist = await RegisterFunction.userExists(username.text);
    if (isUsernameExist) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Neighboard Says..'),
            content: Text("The Username ${username.text}\nis already in use."),
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
      setState(() {
        isLoading = false;
      });
      return;
    }

    String registerResult =
        await RegisterFunction.registerUser(email.text, password.text);

    if (registerResult == "true") {
      await RegisterFunction.sendEmailVerification().then(
        (value) => infoMessage(
          title: "Email Sent!",
          desc: "Check your email, Thanks!",
          context: context,
          duration: 5,
        ),
      );

      // ignore: use_build_context_synchronously
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Email Sent!"),
          content: const Text(
              "Check your email and click\nthe link attached on it to verify your email.\nClick 'DONE' when you're done. Thank you!"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await RegisterFunction.sendEmailVerification().then(
                  (value) => infoMessage(
                    title: "Email Sent!",
                    desc: "Check your email, Thanks!",
                    context: context,
                    duration: 5,
                  ),
                );
              },
              child: const Text("Resend"),
            ),
            ElevatedButton(
              onPressed: () async {
                isVerified = await RegisterFunction.checkEmailVerification();
                if (isVerified) {
                  saveInfo(result[0].hoaId);
                } else {
                  // ignore: use_build_context_synchronously
                  errorMessage(
                      title: "Email not verified!",
                      desc: "Check your email and try again",
                      context: context,
                      duration: 6);
                }
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text("DONE"),
            ),
          ],
        ),
      );
    } else {
      // ignore: use_build_context_synchronously
      errorMessage(
          title: "Something went wrong!",
          desc: registerResult,
          context: context);
    }

    setState(() {
      isLoading = false;
    });
  }

  saveInfo(String hoaId) async {
    bool status = await RegisterFunction.saveUserDetails(
      email: email.text,
      firstName: firstName.text,
      lastName: lastName.text,
      suffix: suffix.text,
      username: username.text,
      gender: gender,
      address: "Blk ${tcBlock.text} Lot ${tcLot.text}, $street",
      cNo: tcCNo.text,
    );

    if (status) {
      await SiteSettingsFunction.registerHOA(hoaId);
      // ignore: use_build_context_synchronously
      await MyMFA.enrollMultiFactorAuthentication(tcCNo.text, context);
    }
  }

  @override
  void initState() {
    super.initState();
    getHOAList();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    confPassword.dispose();
    firstName.dispose();
    lastName.dispose();
    suffix.dispose();
    username.dispose();
    tcBlock.dispose();
    tcLot.dispose();
    tcCNo.dispose();
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
                    ElevatedButton(
                      onPressed: () {
                        Routes().navigate("Login", context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor:
                            Theme.of(context).colorScheme.onBackground,
                        elevation: 0,
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor:
                            Theme.of(context).colorScheme.inversePrimary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onBackground,
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
                body: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 30.w, vertical: 0),
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 20),
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
                                    'Get more features and priviliges by joining the Villa Roma 5 Community',
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
                                      final alpha = RegExp(r'^[a-zA-Z ]+$');
                                      if (!alpha.hasMatch(value)) {
                                        return "Symbols and Numbers are not allowed.";
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
                                      final alpha = RegExp(r'^[a-zA-Z ]+$');
                                      if (!alpha.hasMatch(value)) {
                                        return "Symbols and Numbers are not allowed.";
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
                                    controller: suffix,
                                    onFieldSubmitted: (value) {
                                      if (_formKey.currentState!.validate()) {
                                        onCreateAccount(context);
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return null;
                                      }
                                      final alpha = RegExp(r'^[a-zA-Z 0-9]+$');
                                      if (!alpha.hasMatch(value)) {
                                        return "Symbols are not allowed.";
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Suffix',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text("Gender: "),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: ["Male", "Female", "Others"]
                                        .map(
                                          (e) => Row(
                                            children: [
                                              Radio(
                                                value: e,
                                                groupValue: gender,
                                                onChanged: (val) {
                                                  if (val != null) {
                                                    setState(() {
                                                      gender = val;
                                                    });
                                                  }
                                                },
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      gender = e;
                                                    });
                                                  },
                                                  child: Text(e)),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  if (gender == "Others")
                                    TextFormField(
                                      onSaved: (newValue) {
                                        gender = newValue ?? "";
                                      },
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'Please specify...',
                                      ),
                                      validator: (value) {
                                        if ((value == null || value.isEmpty) &&
                                            gender == "Others") {
                                          return "Specify gender";
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
                                      if (profanityFilter.hasProfanity(value)) {
                                        return "Don't use bad words";
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
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Block"),
                                      const SizedBox(width: 5),
                                      TextFormField(
                                        controller: tcBlock,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d{0,2}$'),
                                          ),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "*";
                                          }
                                          return null;
                                        },
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          constraints: BoxConstraints(
                                            maxWidth: 50,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Text("Lot"),
                                      const SizedBox(width: 5),
                                      TextFormField(
                                        controller: tcLot,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d{0,2}$'),
                                          ),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "*";
                                          }
                                          return null;
                                        },
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          constraints: BoxConstraints(
                                            maxWidth: 50,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  DropdownButtonFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        street = value.toString();
                                      });
                                    },
                                    items: siteModel == null
                                        ? []
                                        : siteModel!.siteStreets
                                            .map((String e) {
                                            return DropdownMenuItem<String>(
                                              value: e,
                                              child: Text(e),
                                            );
                                          }).toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return "Street is required";
                                      }
                                      return null;
                                    },
                                    hint: const Text('Street'),
                                    value: street.isEmpty ? null : street,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: tcCNo,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d{0,10}$'),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Contact No. is required";
                                      } else if (value.length != 10) {
                                        return 'Please enter exactly 10 digits';
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                      hintText: 'Contact No',
                                      prefix: Text("+63"),
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
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: confPassword,
                                    obscureText: passToggle,
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      labelText: 'Confirm Password',
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
                                    onFieldSubmitted: (value) {
                                      if (_formKey.currentState!.validate()) {
                                        onCreateAccount(context);
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Retype your password";
                                      }
                                      if (value != password.text) {
                                        return "Password don't match";
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
                                        _formKey.currentState!.save();
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
