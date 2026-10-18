import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const MrWomensApp());
}

class MrWomensApp extends StatelessWidget {
  const MrWomensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr. Womens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color(0xFFFFF1F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const BillingApp(),
    );
  }
}

class Product {
  final String name;
  final double price;
  final String category;

  Product({required this.name, required this.price, required this.category});
}

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

class BillingApp extends StatefulWidget {
  const BillingApp({super.key});

  @override
  State<BillingApp> createState() => _BillingAppState();
}

class _BillingAppState extends State<BillingApp> with SingleTickerProviderStateMixin {
  int _billNumber = 1001;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();

  late TabController _tabController;
  final List<String> _categories = ['Anti Tanishq', 'Hair Accessories', 'Kids'];

  final List<Product> _allProducts = [
    // Anti Tanishq
    Product(name: 'Gold Polish Necklace', price: 650.0, category: 'Anti Tanishq'),
    Product(name: 'Designer Bangles', price: 350.0, category: 'Anti Tanishq'),
    Product(name: 'Stone Studded Earrings', price: 180.0, category: 'Anti Tanishq'),
    Product(name: 'Fashion Bracelet', price: 240.0, category: 'Anti Tanishq'),
    Product(name: 'Traditional Ring', price: 120.0, category: 'Anti Tanishq'),

    // Hair Accessories
    Product(name: 'Floral Hair Clip', price: 60.0, category: 'Hair Accessories'),
    Product(name: 'Satin Hair Band', price: 90.0, category: 'Hair Accessories'),
    Product(name: 'Scrunchie Pack', price: 50.0, category: 'Hair Accessories'),
    Product(name: 'Pearl Hair Pin', price: 40.0, category: 'Hair Accessories'),
    Product(name: 'Banana Clip Set', price: 75.0, category: 'Hair Accessories'),

    // Kids
    Product(name: 'Kids Hair Clips Pack', price: 80.0, category: 'Kids'),
    Product(name: 'Baby Bangles Pair', price: 120.0, category: 'Kids'),
    Product(name: 'Cartoon Hair Band', price: 70.0, category: 'Kids'),
    Product(name: 'Kids Mini Jewellery Set', price: 250.0, category: 'Kids'),
  ];

  final List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    super.dispose();
  }

  double get _grandTotal {
    return _cart.fold(0.0, (sum, item) => sum + item.total);
  }

  void _addToCart(Product product) {
    setState(() {
      int index = _cart.indexWhere((item) => item.product.name == product.name);
      if (index != -1) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItem(product: product, customPrice: product.price));
      }
    });
  }

  void _editCartItem(CartItem item) {
    final TextEditingController priceCtrl = TextEditingController(text: item.customPrice.toString());
    final TextEditingController qtyCtrl = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${item.product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'விலை (Price ₹)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'எண்ணிக்கை (Quantity)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _cart.remove(item);
              });
              Navigator.pop(ctx);
            },
            child: const Text('நீக்கு (Delete)', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              final double? newPrice = double.tryParse(priceCtrl.text);
              final int? newQty = int.tryParse(qtyCtrl.text);
              if (newPrice != null && newQty != null && newQty > 0) {
                setState(() {
                  item.customPrice = newPrice;
                  item.quantity = newQty;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('சேமி (Save)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _completeBillAndNext() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('கார்ட்டில் பொருட்கள் எதுவும் இல்லை!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('பில் நிறைவு'),
        content: Text('பில் #$_billNumber வெற்றிகரமாக சேமிக்கப்பட்டது. அடுத்த புதிய பில் தொடங்கவா?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('இல்லை'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            onPressed: () {
              setState(() {
                _billNumber++;
                _cart.clear();
                _customerNameController.clear();
                _customerPhoneController.clear();
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('புதிய பில் #$_billNumber தயார்!')),
              );
            },
            child: const Text('ஆம் (Next Bill)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareOnWhatsApp() async {
    if (_cart.isEmpty) return;

    final String dateStr = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
    final StringBuffer billText = StringBuffer();
    billText.writeln('*MR. WOMENS*');
    billText.writeln('Bill No: #$_billNumber');
    billText.writeln('Date: $dateStr');
    if (_customerNameController.text.isNotEmpty) {
      billText.writeln('Customer: ${_customerNameController.text}');
    }
    billText.writeln('--------------------------------');

    for (var item in _cart) {
      billText.writeln('${item.product.name}');
      billText.writeln('₹${item.customPrice.toStringAsFixed(2)} x ${item.quantity} = ₹${item.total.toStringAsFixed(2)}');
    }

    billText.writeln('--------------------------------');
    billText.writeln('*Total Amount: ₹${_grandTotal.toStringAsFixed(2)}*');
    billText.writeln('--------------------------------');
    billText.writeln('Thank you for shopping with us!');

    String phone = _customerPhoneController.text.trim();
    phone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.length == 10) {
      phone = '91$phone';
    }

    final Uri url = Uri.parse(
      phone.isNotEmpty
          ? 'https://wa.me/$phone?text=${Uri.encodeComponent(billText.toString())}'
          : 'https://wa.me/?text=${Uri.encodeComponent(billText.toString())}',
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp திறக்க முடியவில்லை.')),
        );
      }
    }
  }

  Future<void> _printReceipt() async {
    if (_cart.isEmpty) return;

    final doc = pw.Document();
    final dateStr = DateFormat('dd-MM-yyyy hh:
    
