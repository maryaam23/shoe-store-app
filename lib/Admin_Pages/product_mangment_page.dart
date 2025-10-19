import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String searchQuery = "";
  String visibilityFilter = 'All';
  String stockFilter = 'All';
  double minPrice = 0; // Minimum value of the slider
  double maxPrice = 1000; // Maximum value of the slider
  RangeValues selectedPriceRange = const RangeValues(0, 1000);

  List<String> allCategories = [
    'All',
    'Shoes',
    'Clothes',
    'Accessories',
  ]; // default value
  List<String> allBrands = [
    'All',
    'Nike',
    'Adidas',
    'Puma',
    'Reebok',
    'Columbia',
    'New Balance',
    'Converse',
    'Under Armour',
    'The North Face',
    'Skechers',
    'Roberto Vino',
    'Lee Cooper',
    'Le Coq',
    'Timberland',
    'Nautica',
  ];

  String categoryFilter = 'All';
  String brandFilter = 'All';

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('Nproducts').snapshots().listen((
      snapshot,
    ) {
      final categories = <String>{};
      final brands = <String>{};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['category'] != null &&
            data['category'].toString().isNotEmpty) {
          categories.add(data['category'].toString());
        }
        if (data['brand'] != null && data['brand'].toString().isNotEmpty) {
          brands.add(data['brand'].toString());
        }
      }

      setState(() {
        allCategories = [
          'All',
          ...{'Shoes', 'Clothes', 'Accessories', ...categories}.toList()
            ..sort(),
        ];
        allBrands = [
          'All',
          ...{
              'Nike',
              'Adidas',
              'Puma',
              'Reebok',
              'Columbia',
              'New Balance',
              'Converse',
              'Under Armour',
              'The North Face',
              'Skechers',
              'Roberto Vino',
              'Lee Cooper',
              'Le Coq',
              'Timberland',
              'Nautica',
              ...brands,
            }.toList()
            ..sort(),
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // ✅ Hides keyboard
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.grey[50],
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Products',
            style: TextStyle(
              color: const Color(0xFF0d141c),
              fontWeight: FontWeight.bold,
              fontSize: 0.05 * w,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditProductPage()),
            );
          },
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              0.05 * w,
            ), // slightly rounded for modern feel
          ),
          child: Icon(Icons.add, size: 0.07 * w, color: Colors.white),
        ),

        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0.04 * w,
                vertical: 0.03 * w, // smaller vertical padding
              ),
              child: SizedBox(
                height: 0.07 * h, // adjust height to be smaller
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search products...",
                    prefixIcon: Icon(
                      Icons.search,
                      size: 0.05 * w, // smaller icon
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0.01 * h, // smaller inner padding
                      horizontal: 0.03 * w,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.09 * w),
                    ),
                  ),
                  onChanged: (val) => setState(() => searchQuery = val),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0.02 * w,
                vertical: 0.01 * h,
              ),
              child: Wrap(
                spacing: 0.015 * w,
                runSpacing: 0.01 * h,
                children: [
                  // 👁️ Visibility Filter
                  SizedBox(
                    width: 0.3 * w,
                    child: DropdownButtonFormField<String>(
                      value: visibilityFilter,
                      isDense: true, // make dropdown compact
                      decoration: InputDecoration(
                        labelText: 'Visibility',
                        labelStyle: TextStyle(
                          fontSize: 0.028 * w,
                          color: Colors.black87,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 0.03 * w, // scaled padding
                          vertical: 0.008 * h, // scaled vertical padding
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            0.015 * w,
                          ), // scaled radius
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(
                        fontSize: 0.028 * w,
                        color: Colors.black87,
                      ),
                      items:
                          ['All', 'Visible', 'Hidden']
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                      onChanged:
                          (val) => setState(() => visibilityFilter = val!),
                    ),
                  ),

                  // 📦 Stock Filter
                  SizedBox(
                    width: 0.3 * w,
                    child: DropdownButtonFormField<String>(
                      value: stockFilter,
                      isDense: true,
                      decoration: InputDecoration(
                        labelText: 'Stock',
                        labelStyle: TextStyle(
                          fontSize: 0.028 * w,
                          color: Colors.black87,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 0.03 * w, // scaled padding
                          vertical: 0.008 * h, // scaled vertical padding
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            0.015 * w,
                          ), // scaled radius
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(
                        fontSize: 0.028 * w,
                        color: Colors.black87,
                      ),
                      items:
                          ['All', 'In Stock', 'Out of Stock']
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => stockFilter = val!),
                    ),
                  ),

                  // 🏷 Category Filter
                  SizedBox(
                    width: 0.3 * w,
                    child: DropdownButtonFormField<String>(
                      value: categoryFilter,
                      isDense: true,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(
                          fontSize: 0.028 * w,
                          color: Colors.black87,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 0.03 * w, // scaled padding
                          vertical: 0.008 * h, // scaled vertical padding
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            0.015 * w,
                          ), // scaled radius
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(
                        fontSize: 0.028 * w,
                        color: Colors.black87,
                      ),
                      items:
                          allCategories
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => categoryFilter = val!),
                    ),
                  ),

                  // 🏷 Brand Filter
                  SizedBox(
                    width: 0.31 * w,
                    child: DropdownButtonFormField<String>(
                      value: brandFilter,
                      isDense: true,
                      decoration: InputDecoration(
                        labelText: 'Brand',
                        labelStyle: TextStyle(
                          fontSize: 0.028 * w,
                          color: Colors.black87,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 0.03 * w, // scaled padding
                          vertical: 0.008 * h, // scaled vertical padding
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            0.015 * w,
                          ), // scaled radius
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: TextStyle(
                        fontSize: 0.028 * w,
                        color: Colors.black87,
                      ),
                      items:
                          allBrands
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                      onChanged: (val) => setState(() => brandFilter = val!),
                    ),
                  ),

                  // 💲 Price Range Filter
                  SizedBox(
                    width: 0.45 * w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Row for "Price Range" title + From-To labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Price Range",
                              style: TextStyle(
                                fontSize: 0.028 * w, // proportional to width
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "From: \$${selectedPriceRange.start.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize:
                                        0.022 * w, // smaller proportional size
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(
                                  width: 0.02 * w,
                                ), // spacing proportional to width
                                Text(
                                  "To: \$${selectedPriceRange.end.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 0.022 * w,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Small space before slider
                        SizedBox(height: 0.005 * h), // proportional to height
                        // Smaller RangeSlider using SliderTheme
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 0.005 * h, // proportional to height
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius:
                                  0.015 * w, // proportional to width
                            ),
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 0.03 * w, // proportional to width
                            ),
                          ),
                          child: RangeSlider(
                            values: selectedPriceRange,
                            min: minPrice,
                            max: maxPrice,
                            activeColor: const Color.fromARGB(
                              216,
                              79,
                              125,
                              253,
                            ),
                            inactiveColor: const Color.fromARGB(
                              91,
                              108,
                              184,
                              255,
                            ),
                            divisions: 100,
                            labels: RangeLabels(
                              "\$${selectedPriceRange.start.toStringAsFixed(0)}",
                              "\$${selectedPriceRange.end.toStringAsFixed(0)}",
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                selectedPriceRange = values;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('Nproducts')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No products found.",
                        style: TextStyle(fontSize: 0.045 * w),
                      ),
                    );
                  }

                  final products =
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final name =
                            (data['name'] ?? '').toString().toLowerCase();
                        final category = (data['category'] ?? '').toString();
                        final brand = (data['brand'] ?? '').toString();
                        final query = searchQuery.toLowerCase();

                        final visible = data['visible'] ?? true;

                        int stock = 0;

                        if (data['variants'] != null &&
                            data['variants'] is Map) {
                          final variants =
                              data['variants'] as Map<String, dynamic>;
                          variants.forEach((color, sizes) {
                            if (sizes is Map<String, dynamic>) {
                              sizes.forEach((size, qty) {
                                if (qty is num) stock += qty.toInt();
                              });
                            }
                          });
                        }

                        final inStock = stock > 0;

                        bool matchesSearch =
                            name.contains(query) ||
                            category.toLowerCase().contains(query);
                        bool matchesVisibility =
                            visibilityFilter == 'All' ||
                            (visibilityFilter == 'Visible' && visible) ||
                            (visibilityFilter == 'Hidden' && !visible);
                        bool matchesStock =
                            stockFilter == 'All' ||
                            (stockFilter == 'In Stock' && inStock) ||
                            (stockFilter == 'Out of Stock' && !inStock);
                        bool matchesCategory =
                            categoryFilter == 'All' ||
                            category == categoryFilter;
                        bool matchesBrand =
                            brandFilter == 'All' || brand == brandFilter;

                        bool matchesPrice = true;
                        final price =
                            (data['price'] is num)
                                ? (data['price'] as num).toDouble()
                                : double.tryParse(
                                      data['price']?.toString() ?? '0',
                                    ) ??
                                    0.0;

                        matchesPrice =
                            price >= selectedPriceRange.start &&
                            price <= selectedPriceRange.end;

                        return matchesSearch &&
                            matchesVisibility &&
                            matchesStock &&
                            matchesCategory &&
                            matchesBrand &&
                            matchesPrice;
                      }).toList();

                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        "No products match your search.",
                        style: TextStyle(fontSize: 0.045 * w),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    padding: EdgeInsets.symmetric(vertical: 0.01 * h),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final data = product.data() as Map<String, dynamic>;

                      final name = data['name'] ?? '';
                      final category = data['category'] ?? '';
                      final brand = data['brand'] ?? '';
                      final clothesType = data['clothesType'] ?? '';
                      // Calculate total stock from variants
                      int stock = 0;
                      if (data['variants'] != null && data['variants'] is Map) {
                        final variants =
                            data['variants'] as Map<String, dynamic>;
                        variants.forEach((color, sizes) {
                          if (sizes is Map<String, dynamic>) {
                            sizes.forEach((size, qty) {
                              if (qty is num) stock += qty.toInt();
                            });
                          }
                        });
                      }

                      // Automatically mark out-of-stock if quantity <= 0
                      final inStock = stock > 0;
                      final visible = data['visible'] ?? true;

                      final price =
                          (data['price'] is int)
                              ? (data['price'] as int).toDouble()
                              : (data['price'] is double)
                              ? data['price'] as double
                              : double.tryParse(
                                    data['price']?.toString() ?? '0',
                                  ) ??
                                  0.0;

                      final imageUrl = data['image'] ?? '';

                      return ProductItem(
                        id: product.id,
                        name: name,
                        category: category,
                        clothesType: clothesType,
                        stock: stock,
                        price: price,
                        imageUrl: imageUrl,
                        inStock: inStock,
                        visible: visible,
                        brand: brand,
                        w: w,
                        h: h,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final String clothesType;
  final int stock;
  final double price;
  final String brand;

  final String imageUrl;
  final bool inStock;
  final bool visible;
  final double w;
  final double h;

  const ProductItem({
    super.key,
    required this.id,
    required this.name,
    required this.category,
    required this.clothesType,
    required this.stock,
    required this.price,
    required this.brand,

    required this.imageUrl,
    required this.inStock,
    required this.visible,
    required this.w,
    required this.h,
  });

  Future<void> deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this product?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                child: const Text('Delete'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm ?? false) {
      await FirebaseFirestore.instance.collection('Nproducts').doc(id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Product deleted.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanImageUrl = imageUrl.trim();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.04 * w, vertical: 0.01 * h),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.03 * w),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(0.03 * w),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(0.02 * w),
            child: SizedBox(
              width: 0.14 * w,
              height: 0.14 * w,
              child: Builder(
                builder: (_) {
                  if (cleanImageUrl.isEmpty) {
                    return Icon(Icons.image_not_supported, size: 0.08 * w);
                  } else if (cleanImageUrl.startsWith('http')) {
                    return Image.network(
                      cleanImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              Icon(Icons.image_not_supported, size: 0.08 * w),
                    );
                  } else {
                    final file = File(cleanImageUrl);
                    if (file.existsSync()) {
                      return Image.file(file, fit: BoxFit.cover);
                    } else {
                      return Icon(Icons.image_not_supported, size: 0.08 * w);
                    }
                  }
                },
              ),
            ),
          ),
          title: Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 0.045 * w),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0.005 * h),
              Text(
                "Category: $category | Brand: $brand",
                style: TextStyle(fontSize: 0.035 * w),
              ),

              SizedBox(height: 0.005 * h),
              Row(
                children: [
                  Text(
                    "Stock: $stock",
                    style: TextStyle(
                      fontSize: 0.035 * w,
                      color: stock <= 5 ? Colors.red : Colors.black87,
                      fontWeight: stock <= 5 ? FontWeight.bold : null,
                    ),
                  ),
                  SizedBox(width: 0.03 * w),
                  Text(
                    "₪${price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 0.035 * w,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.005 * h),
              inStock
                  ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 0.025 * w,
                      vertical: 0.002 * h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(0.02 * w),
                    ),
                    child: Text(
                      "In Stock",
                      style: TextStyle(
                        fontSize: 0.03 * w,
                        color: Colors.green[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 0.025 * w,
                      vertical: 0.002 * h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(0.02 * w),
                    ),
                    child: Text(
                      "Out of Stock",
                      style: TextStyle(
                        fontSize: 0.03 * w,
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              // 🧩 Visibility status for admin
              if (!visible)
                Container(
                  margin: EdgeInsets.only(top: 0.005 * h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.02 * w,
                    vertical: 0.003 * h,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(0.02 * w),
                  ),
                  child: Text(
                    "Hidden from users",
                    style: TextStyle(
                      fontSize: 0.03 * w,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditProductPage(productId: id),
                  ),
                );
              } else if (value == 'delete') {
                deleteProduct(context);
              }
            },
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
          ),
        ),
      ),
    );
  }
}

/// ----------------------
/// Add/Edit Product Page
/// ----------------------
class AddEditProductPage extends StatefulWidget {
  final String? productId;
  const AddEditProductPage({super.key, this.productId});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> productData = {
    'name': '',
    'brand': '',
    'category': '',
    'clothesType': '',
    'description': '',
    'image': '',
    'price': 0.0,

    'sku': '',

    'variants': <String, Map<String, int>>{}, // color -> {size: quantity}
    'inStock': true,
    'visible': true, // ✅ new field
  };

  final imageUrlController = TextEditingController();

  bool isLoading = false;
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) _loadProduct();
  }

  // Fixed Add Color Dialog
  // Fixed Add Color Dialog with Color Picker Wheel
  Future<Map<String, dynamic>?> pickColorDialog(BuildContext context) async {
    Color selectedColor = Colors.red; // Default
    final Map<String, int> sizeQtyMap = {};

    final sizeController = TextEditingController();
    final qtyController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text("Add Color & Sizes"),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 🔴 Color Picker Circle
                        ColorPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) {
                            setState(() => selectedColor = color);
                          },
                          showLabel: true,
                          pickerAreaHeightPercent: 0.6,
                        ),
                        SizedBox(height: 10),
                        Column(
                          children:
                              sizeQtyMap.entries.map((e) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text("${e.key}: ${e.value}"),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          sizeQtyMap.remove(e.key);
                                        });
                                      },
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: sizeController,
                                decoration: InputDecoration(labelText: 'Size'),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: qtyController,
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.green),
                              onPressed: () {
                                final size = sizeController.text.trim();
                                final qty =
                                    int.tryParse(qtyController.text.trim()) ??
                                    0;
                                if (size.isNotEmpty && qty > 0) {
                                  setState(() {
                                    sizeQtyMap[size] = qty;
                                  });
                                  sizeController.clear();
                                  qtyController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Commit the last size & qty entered (if any)
                        final lastSize = sizeController.text.trim();
                        final lastQty =
                            int.tryParse(qtyController.text.trim()) ?? 0;
                        if (lastSize.isNotEmpty && lastQty > 0) {
                          sizeQtyMap[lastSize] = lastQty;
                        }

                        if (sizeQtyMap.isEmpty) return;

                        Navigator.pop(context, {
                          'color':
                              '#${selectedColor.value.toRadixString(16).substring(2)}',
                          'sizes': Map<String, int>.from(sizeQtyMap),
                        });
                      },
                      child: Text("Add Color"),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _loadProduct() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final doc =
        await FirebaseFirestore.instance
            .collection('Nproducts')
            .doc(widget.productId)
            .get();

    if (!mounted) return; // ✅ important

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        productData.addAll(data);

        productData['variants'] =
            (data['variants'] as Map<String, dynamic>?)?.map(
              (color, sizes) => MapEntry(
                color,
                (sizes as Map<String, dynamic>).map(
                  (size, qty) => MapEntry(size, (qty as num).toInt()),
                ),
              ),
            ) ??
            {};

        imageUrlController.text = data['image'] ?? '';

        int totalQty = 0;
        (productData['variants'] as Map<String, Map<String, int>>).forEach((
          color,
          sizes,
        ) {
          sizes.forEach((size, qty) {
            totalQty += qty;
          });
        });
        productData['inStock'] = totalQty > 0;
      });
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> pickImage(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text("Camera"),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.drive_folder_upload),
                title: const Text("Files"),
                onTap: () => Navigator.pop(context, 'file'),
              ),
            ],
          ),
    );

    if (choice == null) return;

    if (choice == 'file') {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        setState(() {
          pickedImage = File(result.files.single.path!);
          productData['image'] = pickedImage!.path;
          imageUrlController.text = pickedImage!.path;
        });
      }
    } else {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) {
        setState(() {
          pickedImage = File(image.path);
          productData['image'] = pickedImage!.path;
          imageUrlController.text = pickedImage!.path;
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    int totalQty = 0;
    (productData['variants'] as Map<String, Map<String, int>>).forEach((
      color,
      sizes,
    ) {
      sizes.forEach((size, qty) {
        totalQty += qty;
      });
    });
    productData['inStock'] = totalQty > 0;

    productData['image'] =
        pickedImage != null
            ? pickedImage!.path
            : imageUrlController.text.trim();

    if (!mounted) return;
    setState(() => isLoading = true);

    final collection = FirebaseFirestore.instance.collection('Nproducts');

    if (widget.productId == null) {
      await collection.add({...productData, 'createdAt': Timestamp.now()});
    } else {
      await collection.doc(widget.productId).update(productData);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.productId == null ? "Product added!" : "Product updated!",
        ),
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Widget buildTextField(
    String label,
    String key,
    double w, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.015 * w),
      child: TextFormField(
        initialValue: productData[key]?.toString(),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0.03 * w),
          ),
        ),
        validator:
            (value) => (value == null || value.isEmpty) ? 'Enter $label' : null,
        onSaved: (value) {
          if (isNumber) {
            final parsed = double.tryParse(value ?? '');
            productData[key] =
                (parsed != null && parsed % 1 == 0)
                    ? parsed.toInt()
                    : parsed ?? 0.0;
          } else {
            productData[key] = value?.trim() ?? '';
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    imageUrlController.dispose();
    super.dispose();
  }

  void _updateInStock() {
    int totalQty = 0;
    (productData['variants'] as Map<String, Map<String, int>>).forEach((
      color,
      sizes,
    ) {
      sizes.forEach((size, qty) {
        totalQty += qty;
      });
    });
    productData['inStock'] = totalQty > 0;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isEditing = widget.productId != null;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // ✅ Hides keyboard
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          title: Text(
            isEditing ? 'Edit Product' : 'Add Product',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 0.05 * w,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 0.05 * w,
                    vertical: 0.03 * h,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(0.05 * w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 🖼️ Image Picker
                          Center(
                            child: GestureDetector(
                              onTap: () => pickImage(context),
                              child: Container(
                                width: double.infinity,
                                height: 0.25 * h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  image:
                                      pickedImage != null
                                          ? DecorationImage(
                                            image: FileImage(pickedImage!),
                                            fit: BoxFit.cover,
                                          )
                                          : (imageUrlController
                                                  .text
                                                  .isNotEmpty &&
                                              (imageUrlController.text
                                                      .startsWith('http') ||
                                                  imageUrlController.text
                                                      .startsWith('https')))
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              imageUrlController.text,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                ),
                                child:
                                    pickedImage == null &&
                                            (imageUrlController.text.isEmpty ||
                                                !imageUrlController.text
                                                    .startsWith('http'))
                                        ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_a_photo,
                                              size: 0.07 * w,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(height: 0.01 * h),
                                            Text(
                                              'Tap to upload product image',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        )
                                        : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 0.02 * h),

                          /// 🔗 Image URL
                          TextFormField(
                            controller: imageUrlController,
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                              hintText: 'https://example.com/image.jpg',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            onChanged: (val) {
                              setState(() {
                                productData['image'] = val;
                                pickedImage = null;
                              });
                            },
                          ),

                          SizedBox(height: 0.025 * h),

                          /// 🏷️ Basic Info
                          Text(
                            "Product Details",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 0.045 * w,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 0.01 * h),
                          buildTextField('Name', 'name', w),
                          buildTextField('Brand', 'brand', w),

                          /// 🏷 Category Selection
                          /// 🏷 Category Selection
                          Text(
                            "Category",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 0.04 * w,
                            ),
                          ),
                          SizedBox(height: 0.01 * h),

                          Wrap(
                            spacing: 0.02 * w,
                            children: [
                              for (var cat in [
                                'Shoes',
                                'Clothes',
                                'Accessories',
                              ])
                                ChoiceChip(
                                  label: Text(cat),
                                  selected: productData['category'] == cat,
                                  onSelected: (selected) {
                                    setState(() {
                                      productData['category'] =
                                          selected ? cat : '';
                                    });
                                  },
                                ),
                            ],
                          ),
                          SizedBox(height: 0.015 * h),
                          buildTextField('Clothes Type', 'clothesType', w),

                          SizedBox(height: 0.015 * h),
                          Text(
                            "Description",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 0.04 * w,
                            ),
                          ),
                          SizedBox(height: 0.01 * h),
                          buildTextField('Description', 'description', w),

                          SizedBox(height: 0.025 * h),

                          /// 💰 Price & Stock
                          Text(
                            "Price & SKU Details",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 0.045 * w,
                            ),
                          ),
                          SizedBox(height: 0.01 * h),
                          buildTextField(
                            'Price (₪)',
                            'price',
                            w,
                            isNumber: true,
                          ),

                          buildTextField('SKU', 'sku', w),

                          SizedBox(height: 0.025 * h),

                          /// 🎨 Colors & Sizes
                          SizedBox(height: 0.025 * h),
                          Text(
                            "Variants (Color -> Sizes & Quantity)",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 0.045 * w,
                            ),
                          ),
                          SizedBox(height: 0.01 * h),

                          Column(
                            children: [
                              for (var colorEntry
                                  in productData['variants'].entries.toList())
                                VariantCard(
                                  color: colorEntry.key,
                                  sizesMap: Map<String, int>.from(
                                    colorEntry.value,
                                  ),
                                  onUpdate: (newSizes) {
                                    setState(() {
                                      productData['variants'][colorEntry.key] =
                                          newSizes;
                                      _updateInStock();
                                    });
                                  },

                                  onDelete: () {
                                    setState(() {
                                      productData['variants'].remove(
                                        colorEntry.key,
                                      );
                                    });
                                  },
                                ),

                              SizedBox(height: 0.01 * h),

                              // Add new color button
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await pickColorDialog(context);
                                  if (result != null) {
                                    final color = result['color'] as String;
                                    final sizes = Map<String, int>.from(
                                      result['sizes'],
                                    );

                                    // Ensure variants map exists
                                    if (productData['variants'] == null ||
                                        productData['variants'] is! Map) {
                                      productData['variants'] =
                                          <String, Map<String, int>>{};
                                    }

                                    setState(() {
                                      // Add or replace the color entry
                                      productData['variants'][color] = sizes;
                                      _updateInStock();
                                    });
                                  }
                                },

                                icon: Icon(Icons.add),
                                label: Text("Add Color"),
                              ),
                            ],
                          ),

                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Visible to Users',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            activeColor: Colors.black87,
                            value: productData['visible'] ?? true,
                            onChanged: (val) {
                              setState(() {
                                productData['visible'] = val;
                              });
                            },
                          ),
                          SizedBox(height: 0.025 * h),

                          /// 💾 Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 0.065 * h,
                            child: ElevatedButton.icon(
                              onPressed: _saveProduct,
                              icon: const Icon(
                                Icons.save_outlined,
                                color: Colors.white,
                              ),
                              label: Text(
                                isEditing ? 'Update Product' : 'Add Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 0.04 * w,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }
}

class VariantCard extends StatefulWidget {
  final String color;
  final Map<String, int> sizesMap;
  final Function(Map<String, int>) onUpdate;
  final VoidCallback onDelete;

  const VariantCard({
    super.key,
    required this.color,
    required this.sizesMap,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<VariantCard> createState() => _VariantCardState();
}

class _VariantCardState extends State<VariantCard> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 0.01 * h),
      child: Padding(
        padding: EdgeInsets.all(0.02 * w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Color row
            Row(
              children: [
                Container(
                  width: 0.06 * w,
                  height: 0.06 * w,
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(widget.color.replaceFirst('#', '0xff')),
                    ),
                    borderRadius: BorderRadius.circular(0.02 * w),
                  ),
                ),
                SizedBox(width: 0.02 * w),
                Text(
                  widget.color,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 0.04 * w,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 0.06 * w),
                  onPressed: widget.onDelete,
                ),
              ],
            ),

            SizedBox(height: 0.02 * h),

            /// Sizes & Quantities
            Column(
              children: [
                for (var entry in widget.sizesMap.entries)
                  Padding(
                    padding: EdgeInsets.only(bottom: 0.015 * h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 0.15 * w,
                          child: TextFormField(
                            initialValue: entry.key,
                            decoration: InputDecoration(
                              labelText: 'Size',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 0.015 * h,
                                horizontal: 0.02 * w,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.02 * w),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            style: TextStyle(fontSize: 0.035 * w),
                            onChanged: (val) {
                              final newSizes = Map<String, int>.from(
                                widget.sizesMap,
                              );
                              final qty = newSizes[entry.key]!;
                              newSizes.remove(entry.key);
                              newSizes[val] = qty;
                              if (!mounted) return;
                              widget.onUpdate(newSizes);
                            },
                          ),
                        ),
                        SizedBox(width: 0.02 * w),
                        SizedBox(
                          width: 0.2 * w,
                          child: TextFormField(
                            initialValue: entry.value.toString(),
                            decoration: InputDecoration(
                              labelText: 'Qty',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 0.015 * h,
                                horizontal: 0.02 * w,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(0.02 * w),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: 0.035 * w),
                            onChanged: (val) {
                              final newSizes = Map<String, int>.from(
                                widget.sizesMap,
                              );
                              newSizes[entry.key] = int.tryParse(val) ?? 0;
                              widget.onUpdate(newSizes);
                            },
                          ),
                        ),
                        SizedBox(width: 0.02 * w),
                        IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                            size: 0.06 * w,
                          ),
                          onPressed: () {
                            final newSizes = Map<String, int>.from(
                              widget.sizesMap,
                            );
                            newSizes.remove(entry.key);
                            widget.onUpdate(newSizes);
                          },
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 0.02 * h),

                /// Add new size button
                SizedBox(
                  width: double.infinity,
                  height: 0.065 * h,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final sizeController = TextEditingController();
                      final qtyController = TextEditingController();
                      await showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text('Add Size & Quantity'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: sizeController,
                                    decoration: InputDecoration(
                                      labelText: 'Size',
                                    ),
                                  ),
                                  SizedBox(height: 0.015 * h),
                                  TextField(
                                    controller: qtyController,
                                    decoration: InputDecoration(
                                      labelText: 'Quantity',
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (sizeController.text.isNotEmpty) {
                                      final newSizes = Map<String, int>.from(
                                        widget.sizesMap,
                                      );
                                      newSizes[sizeController.text] =
                                          int.tryParse(qtyController.text) ?? 0;
                                      widget.onUpdate(newSizes);
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Text('Add'),
                                ),
                              ],
                            ),
                      );
                    },
                    icon: Icon(Icons.add, size: 0.06 * w),
                    label: Text(
                      'Add Size',
                      style: TextStyle(fontSize: 0.04 * w),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0.02 * w),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
