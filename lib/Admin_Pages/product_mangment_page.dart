import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductPage()),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, size: 28),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(0.04 * w),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0.03 * w),
                ),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
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
                      final category =
                          (data['category'] ?? '').toString().toLowerCase();
                      final query = searchQuery.toLowerCase();
                      return name.contains(query) || category.contains(query);
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
                    final clothesType = data['clothesType'] ?? '';
                    final stock =
                        (data['quantity'] is double)
                            ? (data['quantity'] as double).toInt()
                            : (data['quantity'] is int)
                            ? data['quantity'] as int
                            : int.tryParse(
                                  data['quantity']?.toString() ?? '0',
                                ) ??
                                0;

                    // Automatically mark out-of-stock if quantity <= 0
                    final inStock = stock > 0;

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
  final String imageUrl;
  final bool inStock;
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
    required this.imageUrl,
    required this.inStock,
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
                "Category: $category | Type: $clothesType",
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
    'quantity': 0,
    'sku': '',
    'colors': <String>[],
    'sizes': <int>[],
    'inStock': true,
  };

  final colorsController = TextEditingController();
  final sizesController = TextEditingController();
  final imageUrlController = TextEditingController();

  bool isLoading = false;
  File? pickedImage;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() => isLoading = true);
    final doc =
        await FirebaseFirestore.instance
            .collection('Nproducts')
            .doc(widget.productId)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        productData.addAll(data);
        colorsController.text =
            (data['colors'] as List<dynamic>?)?.join(', ') ?? '';
        sizesController.text =
            (data['sizes'] as List<dynamic>?)?.join(', ') ?? '';
        imageUrlController.text = data['image'] ?? '';
      });
    }
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

    productData['colors'] =
        colorsController.text.split(',').map((c) => c.trim()).toList();
    productData['sizes'] =
        sizesController.text
            .split(',')
            .map((s) => int.tryParse(s.trim()) ?? 0)
            .toList();
    productData['image'] =
        pickedImage != null
            ? pickedImage!.path
            : imageUrlController.text.trim();

    setState(() => isLoading = true);
    final collection = FirebaseFirestore.instance.collection('Nproducts');

    if (widget.productId == null) {
      await collection.add({...productData, 'createdAt': Timestamp.now()});
    } else {
      await collection.doc(widget.productId).update(productData);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.productId == null ? "Product added!" : "Product updated!",
          ),
        ),
      );
      Navigator.pop(context);
    }
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
    colorsController.dispose();
    sizesController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isEditing = widget.productId != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(0.04 * w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => pickImage(context),
                        child: Container(
                          width: double.infinity,
                          height: 0.3 * h,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(0.03 * w),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 2),
                              ),
                            ],
                            image:
                                pickedImage != null
                                    ? DecorationImage(
                                      image: FileImage(pickedImage!),
                                      fit: BoxFit.cover,
                                    )
                                    : (imageUrlController.text.isNotEmpty &&
                                        (imageUrlController.text.startsWith(
                                              'http',
                                            ) ||
                                            imageUrlController.text.startsWith(
                                              'https',
                                            )))
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
                                          !imageUrlController.text.startsWith(
                                            'http',
                                          ))
                                  ? const Center(
                                    child: Icon(Icons.add_a_photo, size: 50),
                                  )
                                  : null,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (or pick an image above)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          setState(() {
                            productData['image'] = val;
                            pickedImage = null;
                          });
                        },
                      ),
                      SizedBox(height: 0.02 * h),
                      buildTextField('Name', 'name', w),
                      buildTextField('Brand', 'brand', w),
                      buildTextField('Category', 'category', w),
                      buildTextField('Clothes Type', 'clothesType', w),
                      buildTextField('Description', 'description', w),
                      buildTextField('Price', 'price', w, isNumber: true),
                      buildTextField('Quantity', 'quantity', w, isNumber: true),
                      buildTextField('SKU', 'sku', w),
                      SizedBox(height: 0.02 * h),
                      TextFormField(
                        controller: colorsController,
                        decoration: InputDecoration(
                          labelText: 'Colors (comma-separated HEX)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.03 * w),
                          ),
                        ),
                      ),
                      SizedBox(height: 0.02 * h),
                      TextFormField(
                        controller: sizesController,
                        decoration: InputDecoration(
                          labelText: 'Sizes (comma-separated numbers)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0.03 * w),
                          ),
                        ),
                      ),
                      SizedBox(height: 0.02 * h),
                      SwitchListTile(
                        title: const Text('In Stock'),
                        value: productData['inStock'] ?? true,
                        onChanged: (val) {
                          setState(() {
                            productData['inStock'] = val;
                          });
                        },
                      ),
                      SizedBox(height: 0.03 * h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: Text(
                            isEditing ? 'Update Product' : 'Add Product',
                          ),
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            padding: EdgeInsets.symmetric(vertical: 0.018 * h),
                            textStyle: TextStyle(
                              fontSize: 0.045 * w,
                              fontWeight: FontWeight.bold,
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
