import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _selectedGender;
  String? _selectedCity;

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
    final size = MediaQuery.of(context).size;

    // Responsive scaling factors
    final double padding = size.width * 0.05;
    final double spacing = size.height * 0.03;
    final double titleFontSize = size.width * 0.07;
    final double subtitleFontSize = size.width * 0.04;
    final double inputFontSize = size.width * 0.048;
    final double buttonHeight = size.height * 0.065;
    final double buttonFontSize = size.width * 0.05;
    final double iconSize = size.width * 0.06;
    final double socialIconSize = size.width * 0.08;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // dismiss keyboard
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(238, 182, 126, 0.047),
                Color.fromARGB(223, 175, 172, 167),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(padding),
                constraints: BoxConstraints(maxWidth: size.width * 0.92),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * 0.05),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: iconSize * 2),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: titleFontSize,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: iconSize / 2,
                            child: Container(
                              width: iconSize,
                              height: iconSize,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 0, 0, 0),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing),

                      Text(
                        "Create your account below",
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: spacing),

                      // Input fields
                      _buildTextField("Full Name", Icons.person, inputFontSize),
                      SizedBox(height: spacing / 2),
                      _buildTextField("Email", Icons.email, inputFontSize),
                      SizedBox(height: spacing / 2),
                      _buildTextField(
                        "Phone Number",
                        Icons.phone,
                        inputFontSize,
                        keyboardType: TextInputType.phone,
                      ),
                      SizedBox(height: spacing / 2),

                      // Date of Birth
                      TextFormField(
                        controller: _dobController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dobController.text =
                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                            });
                          }
                        },
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Enter Date of Birth"
                                    : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                            size: iconSize,
                          ),
                          labelText: "Date of Birth",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ), // same height
                        ),
                        style: TextStyle(fontSize: inputFontSize),
                      ),
                      SizedBox(height: spacing / 2),

                      // Gender dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        items:
                            _genders
                                .map(
                                  (g) => DropdownMenuItem(
                                    value: g,
                                    child: Text(g),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _selectedGender = val),
                        validator:
                            (value) => value == null ? "Select Gender" : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.grey,
                            size: iconSize,
                          ),
                          labelText: "Gender",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ), // same height
                        ),
                        style: TextStyle(fontSize: inputFontSize),
                      ),
                      SizedBox(height: spacing / 2),

                      // Country fixed
                      DropdownButtonFormField<String>(
                        value: "Palestine",
                        items: const [
                          DropdownMenuItem(
                            value: "Palestine",
                            child: Text("Palestine"),
                          ),
                        ],
                        onChanged: null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.flag,
                            color: Colors.grey,
                            size: iconSize,
                          ),
                          labelText: "Country",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ), // same height
                        ),
                        style: TextStyle(fontSize: inputFontSize),
                      ),
                      SizedBox(height: spacing / 2),

                      // City dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        items:
                            _cities
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => _selectedCity = val!),
                        validator: (val) => val == null ? "Select City" : null,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.location_city,
                            color: Colors.grey,
                            size: iconSize,
                          ),
                          labelText: "City",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              size.width * 0.03,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ), // same height
                        ),
                        style: TextStyle(fontSize: inputFontSize),
                      ),
                      SizedBox(height: spacing / 2),

                      // Password fields
                      _buildTextField(
                        "Password",
                        Icons.lock,
                        inputFontSize,
                        isPassword: true,
                      ),
                      SizedBox(height: spacing / 2),
                      _buildTextField(
                        "Confirm Password",
                        Icons.lock_outline,
                        inputFontSize,
                        isPassword: true,
                        controller: _confirmPasswordController,
                      ),
                      SizedBox(height: spacing),

                      // Submit button
                      Center(
                        child: SizedBox(
                          width: size.width * 0.4,
                          height: buttonHeight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                0,
                                0,
                                0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  size.width * 0.05,
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Form submitted successfully!",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: spacing),

                      // Sign in link
                      Center(
                        child: GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              ),
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: Colors.black54,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: inputFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: spacing),

                      // Social Login
                      Column(
                        children: [
                          Text(
                            "Or Sign in with",
                            style: TextStyle(
                              fontSize: inputFontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: spacing * 0.75),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google
                              IconButton(
                                onPressed: () {},
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color.fromARGB(176, 198, 196, 196),
                                  ),
                                  padding: EdgeInsets.all(socialIconSize * 0.3),
                                ),
                                icon: SvgPicture.string(
                                  '''
                                  <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 488 512">
                                  <path d="M488 261.8C488 403.3 391.1 504 248 504 110.8 504 0 393.2 0 256S110.8 8 248 8c66.8 0 123 24.5 166.3 64.9l-67.5 64.9C258.5 52.6 94.3 116.6 94.3 256c0 86.5 69.1 156.6 153.7 156.6 98.2 0 135-70.4 140.8-106.9H248v-85.3h236.1c2.3 12.7 3.9 24.9 3.9 41.4z"/>
                                  </svg>
                                  ''',
                                  width: socialIconSize,
                                  height: socialIconSize,
                                ),
                              ),
                              SizedBox(width: spacing / 1.5),
                              // facebook
                              IconButton(
                                onPressed: () {},
                                style: IconButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    7,
                                    109,
                                    242,
                                  ),
                                  padding: EdgeInsets.all(socialIconSize * 0.3),
                                ),
                                icon: SvgPicture.string(
                                  '''
                                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512">
  <path fill="white" d="M279.14 288l14.22-92.66h-88.91V117.36c0-25.35 12.42-50.06 52.24-50.06h40.42V6.26S293.67 0 262.4 0c-73.22 0-121.12 44.38-121.12 124.72v70.62H83.88V288h57.4v224h104.1V288z"/>
</svg>
''',
                                  width: socialIconSize,
                                  height: socialIconSize,
                                ),
                              ),
                              SizedBox(width: spacing / 1.5),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: spacing * 0.5),

                      // Terms & Conditions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "By signing up, you agree to our Terms & Conditions and Privacy Policy",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF49709c),
                          ),
                        ),
                      ),
                      SizedBox(height: spacing),
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

  Widget _buildTextField(
    String label,
    IconData icon,
    double fontSize, {
    bool isPassword = false,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator:
          (value) => value == null || value.isEmpty ? "Enter $label" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey, size: fontSize * 1.2),
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black54,
        ), // Label color when not focused
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fontSize),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(fontSize),
          borderSide: const BorderSide(
            color: Colors.black, // Border color when focused
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
      ),
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.black, // Text color
      ),
    );
  }
}
