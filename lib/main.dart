import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MrWomensApp());
}

class MrWomensApp extends StatelessWidget {
  const MrWomensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mr. Womens',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD81B60), // Vibrant Pink
          primary: const Color(0xFFC2185B),
          secondary: const Color(0xFFE91E63),
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF7F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFAD1457), // Deep Elegant Pink
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC2185B),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const BillingHomePage(),
    );
  }
}

// Product Model
class Product {
  String id;
  String name;
  String category;
  double price;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
  });
}

// Cart Item Model
class CartItem {
  final Product product;
  int quantity;
  double customPrice;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.customPrice,
  });

  double get total => customPrice * quantity;
}

class BillingHomePage extends StatefulWidget {
  const BillingHomePage({super.key});

  @override
  State<BillingHomePage> createState() => _BillingHomePageState();
}

class _BillingHomePageState extends State<BillingHomePage> {
  // Category List
  List<String> categories = [
    'All',
    'Chains',
    'Bangles',
    'Earrings',
    'Rings',
    'Bracelets',
    'Hair Accessories',
  ];

  String selectedCategory = 'All';
  String searchQuery = '';

  // Initial Product Catalog
  List<Product> products = [
    Product(id: '1', name: '316L Anti-Tarnish Chain', category: 'Chains', price: 350),
    Product(id: '2', name: 'Micro Gold Plated Bangle', category: 'Bangles', price: 420),
    Product(id: '3', name: 'Stainless Steel Ring', category: 'Rings', price: 180),
    Product(id: '4', name: 'Korean Style Studs', category: 'Earrings', price: 120),
    Product(id: '5', name: 'Clover Bracelet', category: 'Bracelets', price: 290),
    Product(id: '6', name: 'Hair Claw Clip', category: 'Hair Accessories', price: 60),
  ];

  List<CartItem> cart = [];

  // Add Item to Cart
  void addToCart(Product product) {
    setState(() {
      int index = cart.indexWhere((item) => item.product.id == product.id);
      if (index != -1) {
        cart[index].quantity++;
      } else {
        cart.add(CartItem(product: product, customPrice: product.price));
      }
    });
  }

  // Edit Item Price in Cart
  void editCartPrice(CartItem item) {
    TextEditingController priceCtrl =
        TextEditingController(text: item.customPrice.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Price: ${item.product.name}'),
          content: TextField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Selling Price (₹)',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                double? newPrice = double.tryParse(priceCtrl.text);
                if (newPrice != null && newPrice >= 0) {
                  setState(() {
                    item.customPrice = newPrice;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Add or Edit Product Dialog
  void showProductDialog({Product? existingProduct}) {
    TextEditingController nameCtrl =
        TextEditingController(text: existingProduct?.name ?? '');
    TextEditingController priceCtrl = TextEditingController(
        text: existingProduct != null ? existingProduct.price.toStringAsFixed(0) : '');

    List<String> selectableCategories =
        categories.where((c) => c != 'All').toList();
    if (selectableCategories.isEmpty) {
      selectableCategories.add('General');
    }

    String prodCategory = existingProduct?.category ?? selectableCategories.first;
    if (!selectableCategories.contains(prodCategory)) {
      prodCategory = selectableCategories.first;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingProduct == null ? 'Add New Product' : 'Edit Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: prodCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: selectableCategories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => prodCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        border:
