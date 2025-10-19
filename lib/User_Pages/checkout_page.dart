import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_confirmation_page.dart';
import 'dart:math';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final user = FirebaseAuth.instance.currentUser;

  String selectedAddress = "";
  String selectedPayment = "Credit Card";
  String selectedCity = "";
  double shipping = 20.0;

  // Controllers for dynamic payment info
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController cardNumberCtrl = TextEditingController();
  final TextEditingController expiryCtrl = TextEditingController();
  final TextEditingController cvvCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  TextEditingController notesController = TextEditingController();

  List<Map<String, dynamic>> addresses = [];
  List<Map<String, dynamic>> phones = [];
  String selectedPhone = "";

  final List<Map<String, dynamic>> payments = [
    {"label": "Credit Card", "value": "Credit Card", "icon": Icons.credit_card},
    {
      "label": "Cash on Delivery",
      "value": "Cash on Delivery",
      "icon": Icons.money,
    },
    {
      "label": "PayPal",
      "value": "PayPal",
      "icon": Icons.account_balance_wallet,
    },
    {"label": "Apple Pay", "value": "Apple Pay", "icon": Icons.apple},
  ];

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

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _loadPaymentMethod();
    _loadUserCity();
    _loadPhoneNumbers();
  }

  Future<void> _loadAddresses() async {
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid);
    final snapshot = await userDoc.get();
    final Map<String, dynamic>? data = snapshot.data();

    List<Map<String, dynamic>> tempAddresses = [];

    final Map<String, dynamic>? savedAddr =
        data?['savedAddress'] as Map<String, dynamic>?;
    if (savedAddr != null) {
      tempAddresses.add({
        "label": "Saved Address",
        "value": "saved",
        "details": savedAddr['address']?.toString() ?? "No address saved",
        "icon": Icons.home,
      });
    }

    final List<dynamic>? savedAddressesList =
        data?['addresses'] as List<dynamic>?;
    if (savedAddressesList != null) {
      for (int i = 0; i < savedAddressesList.length; i++) {
        final addrMap = savedAddressesList[i] as Map<String, dynamic>?;
        tempAddresses.add({
          "label": addrMap?['label']?.toString() ?? "New Address ${i + 1}",
          "details": addrMap?['address']?.toString() ?? "",
          "value": "addr_$i",
          "icon": Icons.location_on,
        });
      }
    }

    if (tempAddresses.isNotEmpty)
      selectedAddress = tempAddresses.first['value'] ?? "";
    setState(() => addresses = tempAddresses);
  }

  Future<void> _loadPhoneNumbers() async {
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid);
    final snapshot = await userDoc.get();
    final data = snapshot.data();

    List<Map<String, dynamic>> tempPhones = [];
    if (data != null && data["phone"] != null) {
      tempPhones.add({
        "label": "Saved Phone",
        "value": "saved",
        "number": data["phone"],
      });
      selectedPhone = "saved";
      phoneCtrl.text = data["phone"];
    }

    // Add “Add New Phone” option
    tempPhones.add({"label": "Add New Phone", "value": "new", "number": ""});

    setState(() => phones = tempPhones);
  }

  Future<void> _loadPaymentMethod() async {
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid);
    final snapshot = await userDoc.get();
    final Map<String, dynamic>? data = snapshot.data();

    if (data != null) {
      dynamic currentMethod = data["selectedPaymentMethod"];
      String? selectedMethod =
          currentMethod is String ? currentMethod : currentMethod?["type"];
      setState(() => selectedPayment = selectedMethod ?? "Credit Card");

      if (currentMethod is Map) {
        nameCtrl.text = currentMethod["name"] ?? "";
        cardNumberCtrl.text = currentMethod["cardNumber"] ?? "";
        expiryCtrl.text = currentMethod["expiry"] ?? "";
        cvvCtrl.text = currentMethod["cvv"] ?? "";
      }
    }
  }

  Future<void> _loadUserCity() async {
    if (user == null) return;
    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid);
    final snapshot = await userDoc.get();
    final data = snapshot.data();

    if (data != null && data["city"] != null) {
      setState(() {
        selectedCity = data["city"];
        _updateShipping();
      });
    }
  }

  void _updateShipping() {
    const cheapCities = [
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
    ];
    shipping = cheapCities.contains(selectedCity) ? 20.0 : 70.0;
  }

  Future<void> _updatePaymentMethod() async {
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid);

    Map<String, dynamic> paymentData;
    if (selectedPayment == "Cash on Delivery" ||
        selectedPayment == "Apple Pay") {
      paymentData = {"type": selectedPayment};
    } else {
      paymentData = {
        "type": selectedPayment,
        "name": nameCtrl.text,
        "cardNumber": cardNumberCtrl.text,
        "expiry": expiryCtrl.text,
        "cvv": cvvCtrl.text,
      };
    }

    await userDoc.update({
      "selectedPaymentMethod": paymentData,
      "city": selectedCity,
      "phone": phoneCtrl.text.trim(),
    });
  }

  bool _requiresPaymentDetails(String method) {
    return method == "Credit Card" || method == "PayPal";
  }

  double _calculateSubtotal(List<QueryDocumentSnapshot> cartDocs) {
    return cartDocs.fold(
      0,
      (sum, doc) => sum + (doc["price"] * doc["quantity"]),
    );
  }

  String _generateOrderNumber() {
    final rnd = Random();
    return List.generate(10, (_) => rnd.nextInt(10)).join();
  }

  bool _isValidCardNumber(String number) {
    final cleaned = number.replaceAll(' ', '');
    if (cleaned.length != 16 || !RegExp(r'^[0-9]+$').hasMatch(cleaned))
      return false;
    return _luhnCheck(cleaned);
  }

  bool _luhnCheck(String number) {
    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  bool _isValidExpiry(String expiry) {
    final expReg = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!expReg.hasMatch(expiry)) return false;

    final parts = expiry.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}');

    final now = DateTime.now();
    final lastDateOfMonth = DateTime(year, month + 1, 0);
    return lastDateOfMonth.isAfter(now);
  }

  bool _isValidCVV(String cvv) {
    return RegExp(r'^[0-9]{3,4}$').hasMatch(cvv);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool _isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    return RegExp(r'^05\d{8}$').hasMatch(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: w * 0.07),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Checkout",
            style: GoogleFonts.inter(
              fontSize: w * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(user!.uid)
                  .collection("cart")
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final cartDocs = snapshot.data!.docs;
            if (cartDocs.isEmpty)
              return const Center(child: Text("Your cart is empty"));

            final subtotal = _calculateSubtotal(cartDocs);
            _updateShipping();
            final total = subtotal + shipping;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Delivery City", w, h),
                  DropdownButtonFormField<String>(
                    value: selectedCity.isNotEmpty ? selectedCity : null,
                    items:
                        _cities
                            .map(
                              (city) => DropdownMenuItem(
                                value: city,
                                child: Text(
                                  city,
                                  style: GoogleFonts.inter(fontSize: w * 0.04),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (val) => setState(() {
                          selectedCity = val ?? "";
                          _updateShipping();
                        }),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(w * 0.03),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: w * 0.04,
                        vertical: w * 0.03,
                      ),
                    ),
                  ),
                  _sectionTitle("Delivery Address", w, h),
                  ...addresses.map(
                    (addr) => RadioListTile(
                      value: addr["value"],
                      groupValue: selectedAddress,
                      onChanged:
                          (val) => setState(() => selectedAddress = val ?? ""),
                      title: Text(
                        addr["label"] ?? "",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: w * 0.045,
                        ),
                      ),
                      subtitle: Text(
                        addr["details"] ?? "",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF49709C),
                          fontSize: w * 0.035,
                        ),
                      ),
                      secondary: CircleAvatar(
                        backgroundColor: const Color(0xFFE7EDF4),
                        radius: w * 0.07,
                        child: Icon(
                          addr["icon"] ?? Icons.location_on,
                          color: Colors.black,
                          size: w * 0.06,
                        ),
                      ),
                    ),
                  ),
                  _sectionTitle("Phone Number", w, h),
                  ...phones.map((ph) {
                    final isNewPhone = ph["value"] == "new";
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile(
                          value: ph["value"],
                          groupValue: selectedPhone,
                          onChanged:
                              (val) => setState(() {
                                selectedPhone = val ?? "";
                                if (isNewPhone) {
                                  phoneCtrl.text = "";
                                } else {
                                  phoneCtrl.text = ph["number"] ?? "";
                                }
                              }),
                          title: Text(
                            ph["label"] ?? "",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: w * 0.045,
                            ),
                          ),
                          subtitle: Text(
                            ph["number"] ?? "",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF49709C),
                              fontSize: w * 0.035,
                            ),
                          ),
                        ),
                        if (isNewPhone && selectedPhone == "new")
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: h * 0.01),
                            child: _buildTextField(
                              "Enter New Phone Number",
                              phoneCtrl,
                              w,
                              keyboard: TextInputType.phone,
                            ),
                          ),
                      ],
                    );
                  }),
                  _sectionTitle("Payment Method", w, h),
                  ...payments.map((pm) {
                    final showDetails = _requiresPaymentDetails(pm["value"]);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile(
                          value: pm["value"],
                          groupValue: selectedPayment,
                          onChanged:
                              (val) =>
                                  setState(() => selectedPayment = val ?? ""),
                          title: Text(
                            pm["label"] ?? "",
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: w * 0.045,
                            ),
                          ),
                          secondary: CircleAvatar(
                            backgroundColor: const Color(0xFFE7EDF4),
                            radius: w * 0.07,
                            child: Icon(
                              pm["icon"] ?? Icons.payment,
                              color: Colors.black,
                              size: w * 0.06,
                            ),
                          ),
                        ),
                        if (selectedPayment == pm["value"] && showDetails)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                            child: Column(
                              children: [
                                _buildTextField("Name on Card", nameCtrl, w),
                                _buildTextField(
                                  "Card Number",
                                  cardNumberCtrl,
                                  w,
                                  keyboard: TextInputType.number,
                                ),
                                _buildTextField(
                                  "Expiry (MM/YY)",
                                  expiryCtrl,
                                  w,
                                ),
                                _buildTextField(
                                  "CVV",
                                  cvvCtrl,
                                  w,
                                  keyboard: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }),
                  _sectionTitle("Order Summary", w, h),
                  ...cartDocs.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(w * 0.03),
                        child: Builder(
                          builder: (_) {
                            final img = item["image"];
                            if (img == null || img.isEmpty) {
                              return Icon(Icons.image, size: w * 0.12);
                            }
                            // Check if it's a network image
                            if (img.startsWith("http://") ||
                                img.startsWith("https://")) {
                              return Image.network(
                                img,
                                width: w * 0.12,
                                height: w * 0.12,
                                fit: BoxFit.cover,
                              );
                            } else {
                              // Assume local file path
                              return Image.file(
                                File(img),
                                width: w * 0.12,
                                height: w * 0.12,
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        ),
                      ),

                      title: Text(
                        item["name"] ?? "",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: w * 0.045,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quantity: ${item["quantity"]}",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF49709C),
                              fontSize: w * 0.035,
                            ),
                          ),
                          if (item["size"] != null)
                            Padding(
                              padding: EdgeInsets.only(top: h * 0.003),
                              child: Text(
                                "Size: ${item["size"]}",
                                style: GoogleFonts.inter(
                                  fontSize: w * 0.035,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          if (item["color"] != null)
                            Padding(
                              padding: EdgeInsets.only(top: h * 0.003),
                              child: Row(
                                children: [
                                  Text(
                                    "Color: ",
                                    style: GoogleFonts.inter(
                                      fontSize: w * 0.035,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    width: w * 0.04,
                                    height: w * 0.04,
                                    decoration: BoxDecoration(
                                      color: _colorFromHex(
                                        item["color"] ?? "#000000",
                                      ),

                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: Text(
                        "₪${(item["price"] * item["quantity"]).toStringAsFixed(2)}",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: w * 0.045,
                        ),
                      ),
                    ),
                  ),

                  _summaryRow("Subtotal", "₪${subtotal.toStringAsFixed(2)}", w),
                  _summaryRow("Shipping", "₪${shipping.toStringAsFixed(2)}", w),
                  _summaryRow(
                    "Total",
                    "₪${total.toStringAsFixed(2)}",
                    w,
                    bold: true,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: h * 0.02),
                    child: TextField(
                      controller: notesController,
                      maxLines: 3,
                      style: GoogleFonts.inter(fontSize: w * 0.04),
                      decoration: InputDecoration(
                        hintText:
                            "Order Notes (e.g., Leave at door, Gift wrap)",
                        hintStyle: GoogleFonts.inter(
                          color: const Color(0xFF49709C),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(w * 0.03),
                          borderSide: const BorderSide(
                            color: Color(0xFFCEDAE8),
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: EdgeInsets.all(w * 0.04),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(w * 0.04),
            child: SizedBox(
              width: double.infinity,
              height: h * 0.07,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D78F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(w * 0.03),
                  ),
                ),
                onPressed: () async {
                  if (phoneCtrl.text.trim().isEmpty) {
                    _showError("Please enter your phone number.");
                    return;
                  }
                  if (!_isValidPhone(phoneCtrl.text.trim())) {
                    _showError(
                      "Phone number must start with 05 and be 10 digits.",
                    );
                    return;
                  }
                  if (selectedPayment == "Credit Card") {
                    if (nameCtrl.text.trim().isEmpty) {
                      _showError("Please enter the cardholder name.");
                      return;
                    }
                    if (!_isValidCardNumber(cardNumberCtrl.text)) {
                      _showError("Invalid card number.");
                      return;
                    }
                    if (!_isValidExpiry(expiryCtrl.text)) {
                      _showError("Invalid or expired date (MM/YY).");
                      return;
                    }
                    if (!_isValidCVV(cvvCtrl.text)) {
                      _showError("Invalid CVV.");
                      return;
                    }
                  }

                  await _updatePaymentMethod();

                  final cartSnapshot =
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(user!.uid)
                          .collection("cart")
                          .get();
                  final cartDocs = cartSnapshot.docs;
                  final subtotal = _calculateSubtotal(cartDocs);
                  _updateShipping();
                  final total = subtotal + shipping;

                  final orderNumber = _generateOrderNumber();
                  final dateNow = DateTime.now();

                  final userDoc =
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(user!.uid)
                          .get();

                  final customerName =
                      userDoc.data()?['fullName'] ?? "Customer";

                  final orderData = {
                    "orderNumber": orderNumber,
                    "orderDate": dateNow,
                    "subtotal": subtotal,
                    "shipping": shipping,
                    "total": total,
                    "city": selectedCity,
                    "address": selectedAddress,
                    "phone": phoneCtrl.text.trim(),
                    "paymentMethod": selectedPayment,
                    "notes": notesController.text,
                    "userId": user!.uid, // 🔹 add userId
                    "customer": customerName, // 🔹 add customer name
                    "items":
                        cartDocs
                            .map(
                              (doc) => {
                                "name": doc["name"],
                                "price": doc["price"],
                                "quantity": doc["quantity"],
                                "image": doc["image"] ?? "",
                                "productId":
                                    doc.data().containsKey("productId")
                                        ? doc["productId"]
                                        : doc.id,
                                "size": doc["size"] ?? "",
                                "color": doc["color"]?.toString() ?? "#000000",
                              },
                            )
                            .toList(),
                  };

                  // Save order
                  await FirebaseFirestore.instance
                      .collection("users")
                      .doc(user!.uid)
                      .collection("orders")
                      .doc(orderNumber)
                      .set(orderData);

                  for (var item in cartDocs) {
                    final data =
                        item.data()
                            as Map<String, dynamic>; // convert snapshot to Map
                    final productId =
                        data.containsKey("productId")
                            ? data["productId"]
                            : item.id;

                    final productRef = FirebaseFirestore.instance
                        .collection("Nproducts")
                        .doc(productId);

                    await FirebaseFirestore.instance.runTransaction((
                      transaction,
                    ) async {
                      final snapshot = await transaction.get(productRef);

                      if (!snapshot.exists) return;

                     final variants = Map<String, dynamic>.from(snapshot["variants"] ?? {});


                      final colorKey = data["color"] ?? "#000000";
final sizeKey = data["size"]?.toString() ?? "";


                      if (variants.containsKey(colorKey)) {
                        final colorMap = Map<String, dynamic>.from(
                          variants[colorKey],
                        );
                        final currentQty = colorMap[sizeKey] ?? 0;
                        final newQty = max(0, currentQty - item["quantity"]);

                        colorMap[sizeKey] = newQty;
                        variants[colorKey] = colorMap;

                        transaction.update(productRef, {"variants": variants});
                      }
                    });
                  }

                  // Clear cart
                  for (var item in cartDocs) {
                    await FirebaseFirestore.instance
                        .collection("users")
                        .doc(user!.uid)
                        .collection("cart")
                        .doc(item.id)
                        .delete();
                  }

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => OrderConfirmationPage(
                            orderNumber: orderNumber,
                            subtotal: subtotal,
                            shipping: shipping,
                            total: total,
                          ),
                    ),
                  );
                },
                child: Text(
                  "Confirm Purchase",
                  style: GoogleFonts.inter(
                    fontSize: w * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, double w, double h) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, h * 0.02, 0, h * 0.01),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: w * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    double w, {
    bool bold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: w * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF49709C),
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: w * 0.045,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: w * 0.045,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController ctrl,
    double w, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: GoogleFonts.inter(fontSize: w * 0.04),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF49709C),
            fontSize: w * 0.04,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(w * 0.03),
            borderSide: const BorderSide(color: Color(0xFFCEDAE8)),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: EdgeInsets.all(w * 0.04),
        ),
      ),
    );
  }

  Color _colorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // add alpha if not provided
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
