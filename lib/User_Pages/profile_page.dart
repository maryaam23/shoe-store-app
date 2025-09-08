import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    User? user = _auth.currentUser;

    if (user == null) {
      return const Center(child: Text("No user logged in"));
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic>? userData =
            snapshot.data != null && snapshot.data!.exists
                ? snapshot.data!.data() as Map<String, dynamic>
                : null;

        return SingleChildScrollView(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture with edit icon
              Stack(
                children: [
                  CircleAvatar(
                    radius: w * 0.15,
                    backgroundImage:
                        user.photoURL != null
                            ? NetworkImage(user.photoURL!)
                            : const AssetImage("assets/logo.jpg")
                                as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () => _pickAndUploadImage(user, w),
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

              // Name with edit icon
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

              // Email
              Text(
                userData?["email"] ?? user.email ?? "No Email",
                style: TextStyle(fontSize: w * 0.045, color: Colors.grey[700]),
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
              buildEditableInfoCard(
                w,
                "Email",
                userData?["email"] ?? user.email ?? "-",
                user.uid,
                "email",
              ),
              buildEditableInfoCard(w, "User ID", user.uid, user.uid, null),

              // --- Extra Sections --- //
              SizedBox(height: h * 0.02),

              Card(
                child: ListTile(
                  leading: Icon(Icons.location_on, size: w * 0.07),
                  title: Text(
                    "Saved Addresses",
                    style: TextStyle(fontSize: w * 0.045),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: w * 0.05),
                  onTap: () {
                    // 👉 Navigate to Saved Address Page
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     //builder: (context) => const SavedAddressPage(),
                    //   ),
                    // );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: Icon(Icons.credit_card, size: w * 0.07),
                  title: Text(
                    "Payment Methods",
                    style: TextStyle(fontSize: w * 0.045),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: w * 0.05),
                  onTap: () {
                    // 👉 Navigate to Payment Methods Page
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     //builder: (context) => const PaymentMethodPage(),
                    //   ),
                    // );
                  },
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
                  onTap: () {
                    // 👉 Navigate to Order History Page
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     //builder: (context) => const OrderHistoryPage(),
                    //   ),
                    // );
                  },
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
                    Navigator.pushReplacementNamed(context, "/login");
                    // ⚠️ Make sure you have a login route in your app
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

  // 🔹 Editable Info Card
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
      case "Email":
        return Icons.email;
      case "User ID":
        return Icons.fingerprint;
      default:
        return Icons.info;
    }
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
      case "email":
        validator = (value) {
          if (value == null || value.isEmpty) return "Enter email";
          if (!RegExp(r"^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$").hasMatch(value))
            return "Invalid email format";
          if (!value.endsWith(".com")) return "Email must end with .com";
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
          try {
            final parts = value.split("/");
            final dob = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
            final today = DateTime.now();
            if (dob.isAfter(today))
              return "Date of Birth cannot be in the future";
            final age =
                today.year -
                dob.year -
                ((today.month < dob.month ||
                        (today.month == dob.month && today.day < dob.day))
                    ? 1
                    : 0);
            if (age < 13) return "You must be at least 13 years old";
          } catch (e) {
            return "Invalid date format";
          }
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
                field == "gender" || field == "city"
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
                  if (validator != null && validator(ctrl.text) != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(validator(ctrl.text)!)),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(uid)
                      .update({field: ctrl.text});
                  if (field == "fullName")
                    await _auth.currentUser?.updateDisplayName(ctrl.text);
                  if (field == "email")
                    //I HAVE     PROOOOOOOOOLBLEM IN BEEEEEEEELOW LINEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
                    //await _auth.currentUser?.updateEmail(ctrl.text);
                    Navigator.pop(context);
                  setState(() {});
                },
                child: Text("Save", style: TextStyle(fontSize: w * 0.045)),
              ),
            ],
          ),
    );
  }

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

  void _pickAndUploadImage(User user, double w) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String imageUrl = pickedFile.path;

      await user.updatePhotoURL(imageUrl);
      await FirebaseFirestore.instance.collection("users").doc(user.uid).update(
        {"photoURL": imageUrl},
      );
      setState(() {});
    }
  }
}
