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

  // controllers
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // dropdown selections
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
    return Scaffold(
      backgroundColor: Colors.grey[200], // background
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxWidth: 350),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 28,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 12,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Create your account below",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  // Input fields
                  _buildTextField("Full Name", Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField("Email", Icons.email),
                  const SizedBox(height: 10),
                  _buildTextField(
                    "Phone Number",
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),

                  // Date of Birth with picker
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
                      prefixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.grey,
                      ),
                      labelText: "Date of Birth",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Gender dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items:
                        _genders
                            .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() => _selectedGender = val);
                    },
                    validator:
                        (value) => value == null ? "Select Gender" : null,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Colors.grey,
                      ),
                      labelText: "Gender",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Country - fixed to Palestine
                  DropdownButtonFormField<String>(
                    value: "Palestine",
                    items: const [
                      DropdownMenuItem(
                        value: "Palestine",
                        child: Text("Palestine"),
                      ),
                    ],
                    onChanged: null, // disable changes
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.flag, color: Colors.grey),
                      labelText: "Country",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // City dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    items:
                        _cities
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value!;
                      });
                    },
                    validator: (value) => value == null ? "Select City" : null,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_city,
                        color: Colors.grey,
                      ),
                      labelText: "City",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Enter Password"
                                : null,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Confirm Password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Confirm Password";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                      ),
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Form submitted successfully!"),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Sign in link
                  // Sign in link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // Action when the whole text is pressed
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "Sign In",
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- Added Social Buttons & Terms ---
                  const SizedBox(height: 20),

                  // Social Buttons
                  Column(
                children: [
                  const Text(
                    "Or Sign in with",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center all social icons
                    children: [
                      // Google
                      IconButton(
                        onPressed: () {
                          //  handle Google login
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                        ),
                        icon: SvgPicture.string(
                          '''
                          <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 488 512">
                            <path d="M488 261.8C488 403.3 391.1 504 
                            248 504 110.8 504 0 393.2 0 256S110.8 
                            8 248 8c66.8 0 123 24.5 166.3 
                            64.9l-67.5 64.9C258.5 52.6 94.3 
                            116.6 94.3 256c0 86.5 69.1 156.6 
                            153.7 156.6 98.2 0 135-70.4 
                            140.8-106.9H248v-85.3h236.1c2.3 
                            12.7 3.9 24.9 3.9 41.4z"/>
                          </svg>
                          ''',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Apple
                      IconButton(
                        onPressed: () {
                          //  handle Apple login
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        icon: SvgPicture.string(
                          '''
                          <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 384 512">
                            <path fill="white" d="M318.7 268.7c-.2-36.7 
                            16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 
                            20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 
                            141.2 4 184.8 4 273.5q0 39.3 14.4 
                            81.2c12.8 36.7 59 126.7 107.2 
                            125.2 25.2-.6 43-17.9 75.8-17.9 
                            31.8 0 48.3 17.9 76.4 17.9 
                            48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 
                            24.8-61.9 24-72.5-24.1 1.4-52 
                            16.4-67.9 34.9-17.5 19.8-27.8 
                            44.3-25.6 71.9 26.1 2 49.9-11.4 
                            69.5-34.3z"/>
                          </svg>
                          ''',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Twitter
                      IconButton(
                        onPressed: () {
                          //  handle Twitter login
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        icon: SvgPicture.string(
                          '''
                          <svg xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 512 512">
                            <path fill="white" d="M389.2 48h70.6L305.6 
                            224.2 487 464H345L233.7 318.6 106.5 
                            464H35.8L200.7 275.5 26.8 
                            48H172.4L272.9 180.9 389.2 
                            48zM364.4 421.8h39.1L151.1 88h-42L364.4 
                            421.8z"/>
                          </svg>
                          ''',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

                  const SizedBox(height: 12),

                  // Terms & Conditions
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "By signing up, you agree to our Terms & Conditions and Privacy Policy",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF49709c)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Optional: Light/Dark images at the bottom
                  Column(
                    children: [
                      Image.asset(
                        'assets/dark.svg', // replace with your dark image path
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/light.svg', // replace with your light image path
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator:
          (value) => (value == null || value.isEmpty) ? "Enter $label" : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
