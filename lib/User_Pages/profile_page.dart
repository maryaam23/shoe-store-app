import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> _genders = ["Male", "Female", "Other"];
  final List<String> _cities = [
    "Ramallah",
    "Nablus",
    "Hebron",
    "Gaza",
    "Jenin",
    "Tulkarm",
    "Bethlehem",
    "Qalqilya",
    "Jericho",
    "Salfit",
    "Tubas",
    "East Jerusalem",
  ];

  dynamic selectedPayment;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection("users").doc(user.uid).get().then((
        snapshot,
      ) {
        final data = snapshot.data();
        if (data != null && mounted) {
          setState(() {
            selectedPayment = data["selectedPaymentMethod"];
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    User? user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text("No user logged in"));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic>? userData =
            snapshot.data!.data() as Map<String, dynamic>?;

        // ✅ Do NOT overwrite selectedPayment here

        return SingleChildScrollView(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              Stack(
                children: [
                  CircleAvatar(
                    radius: w * 0.15,
                    backgroundImage:
                        userData?["photoURL"] != null
                            ? (userData!["photoURL"].toString().startsWith(
                                  "http",
                                )
                                ? NetworkImage(userData["photoURL"])
                                : FileImage(File(userData["photoURL"]))
                                    as ImageProvider)
                            : const AssetImage("assets/logo.jpg"),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _showImageChoiceDialog(user),
                      child: CircleAvatar(
                        radius: w * 0.05,
                        backgroundColor: Colors.black54,
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: w * 0.05,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.02),

              // Full Name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userData?["fullName"] ?? user.displayName ?? "No Name",
                    style: TextStyle(
                      fontSize: w * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: w * 0.02),
                  IconButton(
                    icon: Icon(Icons.edit, size: w * 0.06),
                    onPressed:
                        () => _editFieldDialog(
                          user.uid,
                          "fullName",
                          "Full Name",
                          userData?["fullName"] ?? "",
                          w,
                        ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.01),

              // Email (fixed, non-editable)
              Card(
                child: ListTile(
                  leading: Icon(Icons.email, size: w * 0.07),
                  title: Text("Email", style: TextStyle(fontSize: w * 0.045)),
                  subtitle: Text(
                    userData?["email"] ?? user.email ?? "-",
                    style: TextStyle(fontSize: w * 0.04),
                  ),
                ),
              ),
              SizedBox(height: h * 0.03),

              // Info Cards
              buildEditableInfoCard(
                w,
                "Phone",
                userData?["phone"] ?? "-",
                user.uid,
                "phone",
              ),
              buildEditableInfoCard(
                w,
                "Date of Birth",
                userData?["dob"] ?? "-",
                user.uid,
                "dob",
              ),
              buildEditableInfoCard(
                w,
                "Gender",
                userData?["gender"] ?? "-",
                user.uid,
                "gender",
              ),
              buildEditableInfoCard(
                w,
                "City",
                userData?["city"] ?? "-",
                user.uid,
                "city",
              ),

              SizedBox(height: h * 0.02),

              Card(
                child: ListTile(
                  leading: Icon(Icons.location_on, size: w * 0.07),
                  title: Text(
                    "Saved Address",
                    style: TextStyle(fontSize: w * 0.045),
                  ),
                  subtitle: Text(
                    userData?["savedAddress"]?["address"] ?? "No address saved",
                    style: TextStyle(fontSize: w * 0.04),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add_location_alt, size: w * 0.06),
                    onPressed: () => _saveCurrentLocation(user),
                  ),
                ),
              ),

              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(Icons.credit_card, size: w * 0.07),
                      title: Text(
                        "Payment Methods",
                        style: TextStyle(fontSize: w * 0.045),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: w * 0.05),
                      onTap: () async {
                        final result = await _showPaymentMethodsDialog(
                          user.uid,
                          w,
                          h,
                        );
                        if (result != null) {
                          setState(() {
                            selectedPayment = result; // update UI immediately
                          });
                        }
                      },
                    ),

                    // Display chosen payment method below ListTile
                    if (selectedPayment != null)
                      Padding(
                        padding: EdgeInsets.only(
                          left: w * 0.04,
                          bottom: h * 0.01,
                        ),
                        child: Text(
                          selectedPayment is String
                              ? selectedPayment // simply "Cash on Delivery"
                              : selectedPayment["type"] == "Visa"
                              ? "Visa - ${_maskCardNumber(selectedPayment["cardNumber"])}"
                              : selectedPayment["type"], // fallback if other type
                          style: TextStyle(
                            fontSize: w * 0.04,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Card(
                child: ListTile(
                  leading: Icon(Icons.history, size: w * 0.07),
                  title: Text(
                    "Order History",
                    style: TextStyle(fontSize: w * 0.045),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: w * 0.05),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    size: w * 0.07,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Logout",
                    style: TextStyle(fontSize: w * 0.045, color: Colors.red),
                  ),
                  onTap: () async {
                    await _auth.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                ),
              ),

              SizedBox(height: h * 0.03),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: h * 0.015,
                    horizontal: w * 0.03,
                  ),
                  textStyle: TextStyle(fontSize: w * 0.045),
                ),
                onPressed:
                    () => _showChangePasswordDialog(user.email ?? "", w, h),
                icon: const Icon(Icons.lock),
                label: const Text("Change Password"),
              ),
            ],
          ),
        );
      },
    );
  }

  String _maskCardNumber(String cardNumber) {
    if (cardNumber.length >= 4) {
      return "**** **** **** ${cardNumber.substring(cardNumber.length - 4)}";
    }
    return cardNumber;
  }

  Widget buildEditableInfoCard(
    double w,
    String title,
    String value,
    String uid,
    String? field,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(_getIcon(title), size: w * 0.07),
        title: Text(title, style: TextStyle(fontSize: w * 0.045)),
        subtitle: Text(value, style: TextStyle(fontSize: w * 0.04)),
        trailing:
            field != null
                ? IconButton(
                  icon: Icon(Icons.edit, size: w * 0.06),
                  onPressed:
                      () => _editFieldDialog(uid, field, title, value, w),
                )
                : null,
      ),
    );
  }

  IconData _getIcon(String title) {
    switch (title) {
      case "Phone":
        return Icons.phone;
      case "Date of Birth":
        return Icons.cake;
      case "Gender":
        return Icons.person;
      case "City":
        return Icons.location_city;
      default:
        return Icons.info;
    }
  }

  void _showImageChoiceDialog(User user) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, user);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.drive_folder_upload),
                  title: const Text("Choose from Drive"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromDrive(user);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Choose from Gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, user);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _pickImage(ImageSource source, User user) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        await _updateUserPhoto(user, pickedFile.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // Fixed Drive picker method
  void _pickFromDrive(User user) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result == null) {
        debugPrint("User canceled the picker");
        return; // user canceled
      }

      String? path = result.files.single.path;
      if (path == null) {
        debugPrint("No valid file path selected");
        return;
      }

      await _updateUserPhoto(user, path);
    } catch (e) {
      debugPrint("Error picking from drive: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image from drive")),
      );
    }
  }

  Future<void> _updateUserPhoto(User user, String path) async {
    setState(() {}); // refresh UI

    // Update Firestore with local path
    await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
      "photoURL": path,
    });

    // Optionally update display photo in Firebase Auth
    await user.updatePhotoURL(path);
  }

  void _editFieldDialog(
    String uid,
    String field,
    String title,
    String currentValue,
    double w,
  ) {
    final ctrl = TextEditingController(text: currentValue);

    String? Function(String?)? validator;

    switch (field) {
      case "fullName":
        validator = (value) {
          if (value == null || value.isEmpty) return "Enter your full name";
          if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value))
            return "Name must contain only letters";
          if (value.length < 3) return "Name must be at least 3 characters";
          return null;
        };
        break;
      case "phone":
        validator = (value) {
          if (value == null || value.isEmpty) return "Enter phone number";
          if (!RegExp(r"^05\d{8}$").hasMatch(value))
            return "Phone must start with 05 and be 10 digits";
          return null;
        };
        break;
      case "dob":
        validator = (value) {
          if (value == null || value.isEmpty) return "Enter Date of Birth";
          return null;
        };
        break;
      case "gender":
      case "city":
        validator =
            (value) => value == null || value.isEmpty ? "Select $title" : null;
        break;
      default:
        validator = null;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Edit $title", style: TextStyle(fontSize: w * 0.05)),
            content:
                field == "dob"
                    ? InkWell(
                      onTap: () async {
                        DateTime initialDate = DateTime.now();
                        if (ctrl.text.isNotEmpty) {
                          try {
                            final parts = ctrl.text.split("/");
                            initialDate = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[1]),
                              int.parse(parts[0]),
                            );
                          } catch (_) {}
                        }
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          ctrl.text =
                              "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: ctrl,
                          decoration: InputDecoration(
                            labelText: title,
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          validator: validator,
                        ),
                      ),
                    )
                    : field == "gender" || field == "city"
                    ? DropdownButtonFormField<String>(
                      value: currentValue.isNotEmpty ? currentValue : null,
                      items:
                          (field == "gender" ? _genders : _cities)
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (val) => ctrl.text = val ?? "",
                      validator: validator,
                      decoration: InputDecoration(labelText: title),
                    )
                    : TextFormField(
                      controller: ctrl,
                      decoration: InputDecoration(labelText: title),
                      validator: validator,
                    ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(fontSize: w * 0.045)),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validate
                  if (validator != null && validator(ctrl.text) != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(validator(ctrl.text)!)),
                    );
                    return;
                  }

                  try {
                    // Close dialog immediately
                    Navigator.pop(context);

                    // Update Firestore
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(uid)
                        .update({field: ctrl.text});

                    // Update display name if fullName changed
                    if (field == "fullName") {
                      await _auth.currentUser?.updateDisplayName(ctrl.text);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Updated successfully")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error updating data")),
                    );
                  }
                },
                child: Text("Save", style: TextStyle(fontSize: w * 0.045)),
              ),
            ],
          ),
    );
  }

  void _pickAndUploadImage(User user, double w) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      String imageUrl = pickedFile.path;
      await user.updatePhotoURL(imageUrl);
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {"photoURL": imageUrl},
      );
      setState(() {});
    }
  }

  Future<void> _saveCurrentLocation(User user) async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
          return;
        }
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String address = "";
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        address =
            "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }

      // Save to Firestore
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {
          "savedAddress": {
            "latitude": position.latitude,
            "longitude": position.longitude,
            "address": address,
          },
        },
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Address saved: $address")));
      setState(() {}); // refresh UI
    } catch (e) {
      debugPrint("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to get current location")),
      );
    }
  }

  //-----------------------------------------------------------------------------------------------------------------------
  Future<dynamic> _showPaymentMethodsDialog(
    String uid,
    double w,
    double h,
  ) async {
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);

    // Get current user data
    DocumentSnapshot snapshot = await userDoc.get();
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

    dynamic currentMethod = data?["selectedPaymentMethod"];
    String? selectedMethod =
        currentMethod is String ? currentMethod : currentMethod?["type"];

    final nameCtrl = TextEditingController(
      text: currentMethod is Map ? currentMethod["name"] : "",
    );
    final cardNumberCtrl = TextEditingController(
      text: currentMethod is Map ? currentMethod["cardNumber"] : "",
    );
    final expiryCtrl = TextEditingController(
      text: currentMethod is Map ? currentMethod["expiry"] : "",
    );
    final cvvCtrl = TextEditingController(
      text: currentMethod is Map ? currentMethod["cvv"] : "",
    );

    dynamic result = await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  "Select Payment Method",
                  style: TextStyle(fontSize: w * 0.05),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        value: "Cash on Delivery",
                        groupValue: selectedMethod,
                        title: const Text("Cash on Delivery"),
                        onChanged:
                            (val) => setState(() => selectedMethod = val),
                      ),
                      RadioListTile<String>(
                        value: "Visa",
                        groupValue: selectedMethod,
                        title: const Text("Visa"),
                        onChanged:
                            (val) => setState(() => selectedMethod = val),
                      ),
                      if (selectedMethod == "Visa")
                        Column(
                          children: [
                            TextField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(
                                labelText: "Card holder full name",
                              ),
                            ),
                            SizedBox(height: h * 0.015),
                            TextField(
                              controller: cardNumberCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Card Number",
                              ),
                            ),
                            SizedBox(height: h * 0.015),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: expiryCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "Expiry Date",
                                      hintText: "MM/YY",
                                    ),
                                  ),
                                ),
                                SizedBox(width: w * 0.02),
                                Expanded(
                                  child: TextField(
                                    controller: cvvCtrl,
                                    decoration: const InputDecoration(
                                      labelText: "CVV",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: w * 0.045),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedMethod == null) return;

                      dynamic newMethod;
                      if (selectedMethod == "Cash on Delivery") {
                        newMethod = "Cash on Delivery";
                      } else {
                        if (nameCtrl.text.isEmpty ||
                            cardNumberCtrl.text.isEmpty ||
                            expiryCtrl.text.isEmpty ||
                            cvvCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all Visa details"),
                            ),
                          );
                          return;
                        }
                        newMethod = {
                          "type": "Visa",
                          "name": nameCtrl.text.trim(),
                          "cardNumber": cardNumberCtrl.text.trim(),
                          "expiry": expiryCtrl.text.trim(),
                          "cvv": cvvCtrl.text.trim(),
                        };
                      }

                      try {
                        // 1️⃣ Update Firestore first
                        await userDoc.update({
                          "selectedPaymentMethod": newMethod,
                        });

                        // 2️⃣ Pop the dialog with result AFTER update
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to save payment method"),
                          ),
                        );
                      }
                    },
                    child: Text("Save", style: TextStyle(fontSize: w * 0.045)),
                  ),
                ],
              );
            },
          ),
    );

    return result; // the method the user selected
  }

  //--------------------------------------------------------------------------------------------------------------------------------
  void _showChangePasswordDialog(String email, double w, double h) {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              "Change Password",
              style: TextStyle(fontSize: w * 0.05),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    labelStyle: TextStyle(fontSize: w * 0.045),
                  ),
                ),
                SizedBox(height: h * 0.015),
                TextField(
                  controller: newPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    labelStyle: TextStyle(fontSize: w * 0.045),
                  ),
                ),
                SizedBox(height: h * 0.015),
                TextField(
                  controller: confirmPassCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm New Password",
                    labelStyle: TextStyle(fontSize: w * 0.045),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(fontSize: w * 0.045)),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    User? user = _auth.currentUser;
                    if (user != null) {
                      if (newPassCtrl.text != confirmPassCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "New password and confirmation do not match",
                            ),
                          ),
                        );
                        return;
                      }
                      AuthCredential credential = EmailAuthProvider.credential(
                        email: email,
                        password: currentPassCtrl.text,
                      );
                      await user.reauthenticateWithCredential(credential);
                      await user.updatePassword(newPassCtrl.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password updated successfully"),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Error: Incorrect current password or invalid new password",
                        ),
                      ),
                    );
                  }
                },
                child: Text("Update", style: TextStyle(fontSize: w * 0.045)),
              ),
            ],
          ),
    );
  }
}
