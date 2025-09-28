import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
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
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get()
          .then((snapshot) {
            final data = snapshot.data();
            if (data != null && mounted) {
              setState(() {
                selectedPayment = data["selectedPaymentMethod"];
              });
              debugPrint(
                "Initial selectedPayment loaded: $selectedPayment",
              ); // ✅ Debug
            }
          })
          .catchError((e) {
            debugPrint("Error loading user data in initState: $e");


            
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

        print("DEBUG: StreamBuilder userData: $userData");

        // ✅ Do NOT overwrite selectedPayment here

        return SingleChildScrollView(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture with trendy design
              Stack(
                children: [
                  // Outer gradient border + shadow
                  Container(
                    width: w * 0.42,
                    height: w * 0.42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: w * 0.2,
                      backgroundColor: Colors.white,
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
                  ),

                  // Gradient overlay for modern effect
                  Container(
                    width: w * 0.42,
                    height: w * 0.42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black26],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Camera button with double-layer & neumorphism style
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showImageChoiceDialog(user),
                      child: Container(
                        width: w * 0.1,
                        height: w * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: w * 0.05,
                          backgroundColor: const Color.fromARGB(
                            255,
                            220,
                            217,
                            217,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            size: w * 0.05,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: h * 0.02),
              //------------------------------------------------------
              // Full Name
              // Full Name Card under profile picture
              Container(
                margin: EdgeInsets.only(top: h * 0.02),
                padding: EdgeInsets.symmetric(
                  vertical: h * 0.015,
                  horizontal: w * 0.04,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      const Color.fromARGB(255, 81, 143, 251).withOpacity(0.8),
                      const Color.fromARGB(255, 174, 191, 241).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        userData?["fullName"] ?? user.displayName ?? "No Name",
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.raleway(
                          fontSize: w * 0.055,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    // Neumorphic-style edit button
                    GestureDetector(
                      onTap:
                          () => _editFieldDialog(
                            user.uid,
                            "fullName",
                            "Full Name",
                            userData?["fullName"] ?? "",
                            w,
                          ),
                      child: Container(
                        padding: EdgeInsets.all(w * 0.015),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.white,
                              offset: Offset(-2, -2),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.blueAccent,
                          size: w * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: h * 0.01),
              //------------------------------------------------------------------------
              // Email (fixed, non-editable)
              // Info Cards Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email (non-editable)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: h * 0.008),
                    padding: EdgeInsets.symmetric(
                      vertical: h * 0.015,
                      horizontal: w * 0.04,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: GoogleFonts.merriweather(
                            fontSize: w * 0.04,
                            fontWeight: FontWeight.w800,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        SizedBox(height: h * 0.005),
                        Text(
                          userData?["email"] ?? user.email ?? "-",
                          style: GoogleFonts.openSans(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Phone
                  buildEditableInfoCardModern(
                    w,
                    h,
                    "Phone",
                    userData?["phone"] ?? "-",
                    user.uid,
                    "phone",
                  ),

                  // Date of Birth
                  buildEditableInfoCardModern(
                    w,
                    h,
                    "Date of Birth",
                    userData?["dob"] ?? "-",
                    user.uid,
                    "dob",
                  ),

                  // Gender
                  buildEditableInfoCardModern(
                    w,
                    h,
                    "Gender",
                    userData?["gender"] ?? "-",
                    user.uid,
                    "gender",
                  ),

                  // City
                  buildEditableInfoCardModern(
                    w,
                    h,
                    "City",
                    userData?["city"] ?? "-",
                    user.uid,
                    "city",
                  ),
                ],
              ),

              SizedBox(height: h * 0.02),

              // Saved Address
              Container(
                margin: EdgeInsets.symmetric(vertical: h * 0.008),
                padding: EdgeInsets.symmetric(
                  vertical: h * 0.02,
                  horizontal: w * 0.04,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text column wrapped in Expanded
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Saved Address",
                            style: GoogleFonts.merriweather(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: h * 0.005),
                          Text(
                            userData?["savedAddress"]?["address"] ??
                                "No address saved",
                            style: GoogleFonts.openSans(
                              fontSize: w * 0.04,
                              color: Colors.black,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: w * 0.02),
                    IconButton(
                      icon: Icon(Icons.add_location_alt, size: w * 0.06),
                      onPressed: () => _saveCurrentLocation(user),
                    ),
                  ],
                ),
              ),

              // Payment Methods
              Container(
                margin: EdgeInsets.symmetric(vertical: h * 0.008),
                padding: EdgeInsets.symmetric(
                  vertical: h * 0.015,
                  horizontal: w * 0.04,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final result = await _showPaymentMethodsDialog(
                          user.uid,
                          w,
                          h,
                        );
                        if (result != null) {
                          print("DEBUG: Payment method selected: $result");
                          setState(() {
                            selectedPayment = result; // update UI
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Payment Methods",
                            style: GoogleFonts.merriweather(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: w * 0.05),
                        ],
                      ),
                    ),
                    if (selectedPayment != null)
                      Padding(
                        padding: EdgeInsets.only(top: h * 0.01),
                        child: Text(
                          selectedPayment is String
                              ? selectedPayment
                              : selectedPayment["type"] == "Visa"
                              ? "Visa - ${_maskCardNumber(selectedPayment["cardNumber"])}"
                              : selectedPayment["type"],
                          style: GoogleFonts.openSans(
                            fontSize: w * 0.04,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Order History
              Container(
                margin: EdgeInsets.symmetric(vertical: h * 0.008),
                padding: EdgeInsets.symmetric(
                  vertical: h * 0.015,
                  horizontal: w * 0.04,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Order History",
                      style: GoogleFonts.merriweather(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: w * 0.05),
                  ],
                ),
              ),

              // Logout
              Container(
                margin: EdgeInsets.symmetric(vertical: h * 0.008),
                padding: EdgeInsets.symmetric(
                  vertical: h * 0.015,
                  horizontal: w * 0.04,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () async {
                    await _auth.signOut();
                    print("DEBUG: User logged out");
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.logout,
                        size: w * 0.07,
                        color: const Color.fromARGB(255, 255, 17, 1),
                      ),
                      SizedBox(width: w * 0.04),
                      Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: w * 0.045,
                          color: const Color.fromARGB(255, 246, 18, 2),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Change Password Button
              SizedBox(height: h * 0.03),
              // Change Password Button - Modern Neumorphic Style
              SizedBox(height: h * 0.03),
              GestureDetector(
                onTap: () => _showChangePasswordDialog(user.email ?? "", w, h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: h * 0.018,
                    horizontal: w * 0.06,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(4, 4),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(-4, -4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, color: Colors.black87, size: w * 0.06),
                      SizedBox(width: w * 0.03),
                      Text(
                        "Change Password",
                        style: GoogleFonts.merriweather(
                          fontSize: w * 0.045,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget buildEditableInfoCardModern(
    double w,
    double h,
    String fieldName,
    String fieldValue,
    String userId,
    String fieldKey,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: h * 0.008),
      padding: EdgeInsets.symmetric(vertical: h * 0.015, horizontal: w * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fieldName,
                style: GoogleFonts.merriweather(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: h * 0.005),
              Text(
                fieldValue,
                style: GoogleFonts.openSans(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap:
                () => _editFieldDialog(
                  userId,
                  fieldKey,
                  fieldName,
                  fieldValue,
                  w,
                ),
            child: Container(
              padding: EdgeInsets.all(w * 0.012),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black12,
              ),
              child: Icon(Icons.edit, size: w * 0.05, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
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
        return print("DEBUG: User canceled file picker"); // user canceled
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
            title: Text(
              "Edit $title",
              style: GoogleFonts.merriweather(
                fontSize: w * 0.05,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
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
      print("DEBUG: Address saved: $address");

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
                  style: GoogleFonts.merriweather(
                    fontSize: w * 0.05,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        value: "Cash on Delivery",
                        groupValue: selectedMethod,
                        title: Text(
                          "Cash on Delivery",
                          style: GoogleFonts.merriweather(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        onChanged:
                            (val) => setState(() => selectedMethod = val),
                      ),
                      RadioListTile<String>(
                        value: "Visa",
                        groupValue: selectedMethod,
                        title: Text(
                          "Visa",
                          style: GoogleFonts.merriweather(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        onChanged:
                            (val) => setState(() => selectedMethod = val),
                      ),
                      if (selectedMethod == "Visa")
                        Column(
                          children: [
                            TextField(
                              controller: nameCtrl,
                              style: GoogleFonts.merriweather(
                                fontSize: w * 0.045,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: "Card holder full name",
                                labelStyle: GoogleFonts.merriweather(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(height: h * 0.015),
                            TextField(
                              controller: cardNumberCtrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.merriweather(
                                fontSize: w * 0.045,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: "Card Number",
                                labelStyle: GoogleFonts.merriweather(
                                  fontSize: w * 0.045,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(height: h * 0.015),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: expiryCtrl,
                                    style: GoogleFonts.merriweather(
                                      fontSize: w * 0.045,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Expiry Date",
                                      hintText: "MM/YY",
                                      labelStyle: GoogleFonts.merriweather(
                                        fontSize: w * 0.045,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: w * 0.02),
                                Expanded(
                                  child: TextField(
                                    controller: cvvCtrl,
                                    style: GoogleFonts.merriweather(
                                      fontSize: w * 0.045,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "CVV",
                                      labelStyle: GoogleFonts.merriweather(
                                        fontSize: w * 0.045,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
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
                    onPressed: () => Navigator.pop(context, null),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.merriweather(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
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
                        await userDoc.update({
                          "selectedPaymentMethod": newMethod,
                        });
                        print("DEBUG: Payment method saved: $newMethod");
                        Navigator.pop(context, newMethod);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to save payment method"),
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Save",
                      style: GoogleFonts.merriweather(
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );

    return result;
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
