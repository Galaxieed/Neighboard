import 'package:flutter/material.dart';
import 'package:neighboard/constants/constants.dart';
import 'package:neighboard/main.dart';
import 'package:neighboard/models/hoa_model.dart';
import 'package:neighboard/src/admin_side/site_settings/site_settings_function.dart';
import 'package:neighboard/src/loading_screen/loading_screen.dart';
import 'package:neighboard/widgets/notification/mini_notif/elegant_notif.dart';

class HOAList extends StatefulWidget {
  const HOAList({super.key});

  @override
  State<HOAList> createState() => _HOAListState();
}

class _HOAListState extends State<HOAList> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String street = '';
  bool isEditing = false, isLoading = true;

  List<HOAModel> hoaModels = [];
  List<HOAModel> copyHoaModels = [];
  getHOAList() async {
    hoaModels = await SiteSettingsFunction.getHOA() ?? [];
    copyHoaModels = hoaModels;
    await getArchivedHOAList();
    setState(() {
      isLoading = false;
    });
  }

  List<HOAModel> archivedHoaModels = [];
  getArchivedHOAList() async {
    archivedHoaModels = await SiteSettingsFunction.getArchivedHOA() ?? [];
  }

  restoreArchiveHOA(HOAModel hoaModel) async {
    bool status = await SiteSettingsFunction.restoreArchiveHOA(hoaModel);
    if (status) {
      // ignore: use_build_context_synchronously
      successMessage(
          title: "Restored!", desc: "This hoa was restored", context: context);
      getHOAList();
      clearFields();
    }
  }

  archiveHOA(HOAModel hoaModel, index) async {
    bool status = await SiteSettingsFunction.archiveHOA(hoaModel);
    if (status) {
      getHOAList();
      // ignore: use_build_context_synchronously
      successMessage(
          title: "Archived!", desc: "Archived Successfully", context: context);
      clearFields();
    }
  }

  archiveAll() async {
    setState(() {
      isLoading = true;
    });
    Future.forEach(hoaModels, (element) async {
      await SiteSettingsFunction.archiveHOA(element);
    }).then((value) {
      getHOAList();
      successMessage(
          title: "Done!", desc: "Table was cleared", context: context);
      isLoading = false;
      clearFields();
    });
  }

  void clearFields() {
    setState(() {
      id = null;
      _fnameController.clear();
      _lnameController.clear();
      _suffixController.clear();
      _searchController.clear();
      street = '';
    });
  }

  String? id;
  onSave() async {
    if (_formKey.currentState!.validate()) {
      final exists = hoaModels.where(
        (element) =>
            element.firstName == _fnameController.text &&
            element.lastName == _lnameController.text &&
            element.suffix == _suffixController.text &&
            element.street == street,
      );

      if (exists.isNotEmpty) {
        errorMessage(
            title: "Exists",
            desc: "This person is already on the list",
            context: context);
        return;
      }

      final archivedExists = archivedHoaModels
          .where(
            (element) =>
                element.firstName == _fnameController.text &&
                element.lastName == _lnameController.text &&
                element.suffix == _suffixController.text &&
                element.street == element.street,
          )
          .toList();

      if (archivedExists.isNotEmpty) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text("Can't add"),
                content:
                    const Text("This person is on archived list.\nRestore?"),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      clearFields();
                      Navigator.pop(context);
                    },
                    child: const Text("No"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      restoreArchiveHOA(archivedExists[0]);
                      Navigator.pop(context);
                    },
                    child: const Text("Yes"),
                  ),
                ],
              );
            });
        return;
      }

      //////////////////////////////////////////////////////

      if (isEditing) {
        //UPDATE
        bool status = await SiteSettingsFunction.updateHOA(
          hoaId: id ?? "",
          firstName: _fnameController.text,
          lastName: _lnameController.text,
          suffix: _suffixController.text,
          street: street,
        );
        if (status) {
          getHOAList();
          // ignore: use_build_context_synchronously
          successMessage(
              title: "Edited!",
              desc: "HOA was edited successfuly",
              context: context);
        }
        isEditing = false;
        clearFields();
      } else {
        //NEW
        HOAModel thisHOA = HOAModel(
          hoaId: DateTime.now().toIso8601String(),
          firstName: _fnameController.text,
          lastName: _lnameController.text,
          suffix: _suffixController.text,
          street: street,
          isRegistered: false,
        );

        bool status = await SiteSettingsFunction.setHOA(hoaModel: thisHOA);
        if (status) {
          getHOAList();
          // ignore: use_build_context_synchronously
          successMessage(
              title: "Added", desc: "New HOA was added!", context: context);
        }
        setState(() {
          _fnameController.clear();
          _lnameController.clear();
          _suffixController.clear();
          _searchController.clear();
        });
      }
    }
  }

  search(String value) {
    hoaModels = copyHoaModels;
    if (value.isNotEmpty) {
      value = value.toLowerCase().trim();
      hoaModels = hoaModels
          .where((element) =>
              element.firstName.toLowerCase().contains(value) ||
              element.lastName.toLowerCase().contains(value) ||
              element.suffix.toLowerCase().contains(value) ||
              element.street.toLowerCase().contains(value))
          .toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getHOAList();
  }

  @override
  void dispose() {
    super.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _suffixController.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const LoadingScreen()
        : Scaffold(
            body: NestedScrollView(
              // Changes the way the inner and outer scroll are linked together
              floatHeaderSlivers: true,
              // This builds the scrollable content above the body
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  title: const Text(
                    "List of HOA",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  pinned: true,
                ),
              ],
              body: Container(
                color: Theme.of(context).colorScheme.background,
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: 1000,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            //TABLE
                            SizedBox(
                              height: 400,
                              child: hoaModels.isEmpty
                                  ? const Center(
                                      child: Text("Empty"),
                                    )
                                  : ListView.separated(
                                      itemCount: hoaModels.length,
                                      itemBuilder: (context, index) {
                                        HOAModel hoaModel = hoaModels[index];
                                        return ListTile(
                                          title: Text(
                                            "${hoaModel.firstName} ${hoaModel.lastName} ${hoaModel.suffix}",
                                          ),
                                          titleTextStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                          subtitle: Text(hoaModel.street),
                                          onTap: () {
                                            setState(() {
                                              isEditing = true;
                                              id = hoaModel.hoaId;
                                              _fnameController.text =
                                                  hoaModel.firstName;
                                              _lnameController.text =
                                                  hoaModel.lastName;
                                              _suffixController.text =
                                                  hoaModel.suffix;
                                              street = hoaModel.street;
                                            });
                                          },
                                          trailing: IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text(
                                                        "Archive Confirmation"),
                                                    content: const Text(
                                                        "Archive this person?"),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text("No"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          archiveHOA(
                                                              hoaModel, index);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            const Text("Yes"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.remove_circle_outline,
                                                color: Colors.redAccent,
                                              )),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) {
                                        return const Divider();
                                      },
                                    ),
                            ),
                            const SizedBox(height: 10),
                            //FIELDS
                            SearchBar(
                              controller: _searchController,
                              leading: const Icon(Icons.search_rounded),
                              onChanged: search,
                            ),
                            const SizedBox(height: 10),
                            BuildMyTextField(
                              controller: _fnameController,
                              label: "First Name",
                              formKey: _formKey,
                              callback: onSave,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "First name is required";
                                }
                                final alpha = RegExp(r'^[a-zA-Z .]+$');
                                if (!alpha.hasMatch(value)) {
                                  return "Symbols and Numbers are not allowed.";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: BuildMyTextField(
                                    controller: _lnameController,
                                    label: "Last Name",
                                    formKey: _formKey,
                                    callback: onSave,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Last name is required";
                                      }
                                      final alpha = RegExp(r'^[a-zA-Z .]+$');
                                      if (!alpha.hasMatch(value)) {
                                        return "Symbols and Numbers are not allowed.";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 1,
                                  child: BuildMyTextField(
                                    controller: _suffixController,
                                    label: "Suffix",
                                    formKey: _formKey,
                                    callback: onSave,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return null;
                                      }
                                      final alpha = RegExp(r'^[a-zA-Z 1-9.]+$');
                                      if (!alpha.hasMatch(value)) {
                                        return "Symbols are not allowed.";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField(
                              onChanged: (value) {
                                setState(() {
                                  street = value.toString();
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Choose Street";
                                }
                                return null;
                              },
                              items: siteModel == null
                                  ? []
                                  : siteModel!.siteStreets.map((String e) {
                                      return DropdownMenuItem<String>(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList(),
                              hint: const Text('Street'),
                              value: street.isEmpty ? null : street,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                if (!isEditing)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Archive All?"),
                                            content: const Text(
                                                "Continue to clear the list?"),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("No"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  archiveAll();
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Yes"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      foregroundColor:
                                          colorFromHex(discardColor),
                                    ),
                                    icon: const Icon(Icons.remove),
                                    label: const Text("Table"),
                                  ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: clearFields,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    foregroundColor: colorFromHex(discardColor),
                                  ),
                                  icon: const Icon(Icons.clear),
                                  label: const Text("Fields"),
                                ),
                                const Spacer(),
                                if (isEditing)
                                  ElevatedButton(
                                    onPressed: () {
                                      isEditing = false;
                                      clearFields();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      foregroundColor:
                                          colorFromHex(discardColor),
                                    ),
                                    child: const Text("Cancel"),
                                  ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: onSave,
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      backgroundColor: colorFromHex(saveColor),
                                      foregroundColor: Colors.white),
                                  child: Text(isEditing ? "Save" : "Add"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

class BuildMyTextField extends StatelessWidget {
  const BuildMyTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    required this.formKey,
    required this.callback,
  });
  final GlobalKey<FormState> formKey;
  final Function callback;
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onFieldSubmitted: (value) {
        if (formKey.currentState!.validate()) {
          callback();
        }
      },
      decoration: InputDecoration(
        label: Text(label),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      validator: validator,
    );
  }
}
