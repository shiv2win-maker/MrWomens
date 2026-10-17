import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MrWomensBillingApp());
}

class MrWomensBillingApp extends StatelessWidget {
  const MrWomensBillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr. Womens Billing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          primary: const Color(0xFFE91E63),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF0F5),
        useMaterial3: true,
      ),
      home: const BillingScreen(),
    );
  }
}

class ProductItem {
  final String name;
  final String category;
  final double defaultPrice;
  final double gstRate;

  ProductItem({
    required this.name,
    required this.category,
    required this.defaultPrice,
    required this.gstRate,
  });
}

class CartItem {
  final ProductItem product;
  int quantity;
  double price;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.price,
  });

  double get total => price * quantity;
}

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  int billNumber = 1042;

  final List<ProductItem> antiTanishqItems = [
    ProductItem(name: 'Kada', category: 'Anti Tanishq', defaultPrice: 1000, gstRate: 0.03),
    ProductItem(name: 'Ring', category: 'Anti Tanishq', defaultPrice: 250, gstRate: 0.03),
    ProductItem(name: 'Bangles', category: 'Anti Tanishq', defaultPrice: 600, gstRate: 0.03),
    ProductItem(name: 'Chain', category: 'Anti Tanishq', defaultPrice: 750, gstRate: 0.03),
    ProductItem(name: 'Watch', category: 'Anti Tanishq', defaultPrice: 1200, gstRate: 0.03),
    ProductItem(name: 'Bracelet', category: 'Anti Tanishq', defaultPrice: 350, gstRate: 0.03),
    ProductItem(name: 'Anklet', category: 'Anti Tanishq', defaultPrice: 500, gstRate: 0.03),
  ];

  final List<ProductItem> hairAccessories = [
    ProductItem(name: 'Normal Clips', category: 'Hair Accessories', defaultPrice: 50, gstRate: 0.12),
    ProductItem(name: 'Premium Clips', category: 'Hair Accessories', defaultPrice: 120, gstRate: 0.12),
    ProductItem(name: 'Bands', category: 'Hair Accessories', defaultPrice: 30, gstRate: 0.12),
    ProductItem(name: 'Accessories', category: 'Hair Accessories', defaultPrice: 80, gstRate: 0.12),
  ];

  final List<ProductItem> kidsItems = [
    ProductItem(name: 'Kids Watch', category: 'Kids', defaultPrice: 250, gstRate: 0.18),
    ProductItem(name: 'Kids Bag', category: 'Kids', defaultPrice: 450, gstRate: 0.18),
    ProductItem(name: 'Keychains', category: 'Kids', defaultPrice: 80, gstRate: 0.18),
    ProductItem(name: 'Accessories', category: 'Kids', defaultPrice: 150, gstRate: 0.18),
  ];

  final List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _addToCart(ProductItem item) {
    setState(() {
      final existingIndex = _cart.indexWhere((c) => c.product.name == item.name && c.product.category == item.category);
      if (existingIndex >= 0) {
        _cart[existingIndex].quantity += 1;
      } else {
        _cart.add(CartItem(product: item, price: item.defaultPrice, quantity: 1));
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cart[index].quantity += delta;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      }
    });
  }

  double get subtotal => _cart.fold(0, (sum, item) => sum + item.total);

  double get gstAntiTanishq => _cart
      .where((item) => item.product.category == 'Anti Tanishq')
      .fold(0, (sum, item) => sum + (item.total * 0.03));

  double get gstHairAcc => _cart
      .where((item) => item.product.category == 'Hair Accessories')
      .fold(0, (sum, item) => sum + (item.total * 0.12));

  double get gstKids => _cart
      .where((item) => item.product.category == 'Kids')
      .fold(0, (sum, item) => sum + (item.total * 0.18));

  double get grandTotal => subtotal + gstAntiTanishq + gstHairAcc + gstKids;

  void _shareViaWhatsApp() async {
    final now = DateTime.now();
    final dateStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final buffer = StringBuffer();
    buffer.writeln("*#$billNumber*");
    buffer.writeln("================================");
    buffer.writeln("*MR WOMENS*");
    buffer.writeln("Tirupur Road - Kangayam");
    buffer.writeln("GSTIN: 33GHWPS6754J1ZA");
    buffer.writeln("Ph: 9600670996");
    buffer.writeln("================================");
    buffer.writeln("Customer: ${_nameController.text.isEmpty ? 'Customer' : _nameController.text}   $dateStr");
    buffer.writeln("Mobile  : ${_mobileController.text}   $timeStr");
    buffer.writeln("--------------------------------");
    buffer.writeln("*Items:*");
    for (var item in _cart) {
      buffer.writeln("${item.product.name} x ${item.quantity} = ₹${item.total.toStringAsFixed(2)}");
    }
    buffer.writeln("--------------------------------");
    buffer.writeln("Subtotal: ₹${subtotal.toStringAsFixed(2)}");
    if (gstAntiTanishq > 0) buffer.writeln("GST 3% (Anti Tanishq): ₹${gstAntiTanishq.toStringAsFixed(2)}");
    if (gstHairAcc > 0) buffer.writeln("GST 12% (Hair Acc): ₹${gstHairAcc.toStringAsFixed(2)}");
    if (gstKids > 0) buffer.writeln("GST 18% (Kids): ₹${gstKids.toStringAsFixed(2)}");
    buffer.writeln("--------------------------------");
    buffer.writeln("*GRAND TOTAL: ₹${grandTotal.toStringAsFixed(2)}*");
    buffer.writeln("================================");
    buffer.writeln("Thank you for shopping! Visit again!");

    final text = Uri.encodeComponent(buffer.toString());
    final phone = _mobileController.text.trim();
    final url = phone.isNotEmpty
        ? "https://wa.me/91$phone?text=$text"
        : "https://wa.me/?text=$text";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  void _printReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing Bill #$billNumber to Bluetooth Printer...'),
        backgroundColor: const Color(0xFFE91E63),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '#$billNumber',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFE91E63)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.woman, color: Color(0xFFE91E63), size: 28),
                      const SizedBox(width: 6),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Mr.',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            TextSpan(
                              text: 'Womens',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tirupur Road - Kangayam',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'GSTIN: 33GHWPS6754J1ZA',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Contact: +91 96006 70996',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE91E63)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Customer Name',
                            prefixIcon: const Icon(Icons.person, size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(dateStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Mobile Number',
                            prefixIcon: const Icon(Icons.phone, size: 18),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(timeStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFE91E63),
                labelColor: const Color(0xFFE91E63),
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'Anti Tanishq (3%)'),
                  Tab(text: 'Hair Acc (12%)'),
                  Tab(text: 'Kids (18%)'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductGrid(antiTanishqItems),
                  _buildProductGrid(hairAccessories),
                  _buildProductGrid(kidsItems),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_cart.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 70),
                      child: ListView.builder(
                        itemCount: _cart.length,
                        itemBuilder: (context, i) {
                          final item = _cart[i];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.product.name} (x${item.quantity})', style: const TextStyle(fontSize: 12)),
                              Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.remove_circle, size: 16, color: Colors.grey),
                                    onPressed: () => _updateQuantity(i, -1),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.add_circle, size: 16, color: Color(0xFFE91E63)),
                                    onPressed: () => _updateQuantity(i, 1),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('₹${item.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  const Divider(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sub Total:', style: TextStyle(fontSize: 13, color: Colors.black87)),
                      Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (gstAntiTanishq > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST 3% (Anti Tanishq):', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('₹${gstAntiTanishq.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  if (gstHairAcc > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST 12% (Hair Acc):', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('₹${gstHairAcc.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  if (gstKids > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST 18% (Kids):', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('₹${gstKids.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Grand Total:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFE91E63))),
                      Text('₹${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFFE91E63))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _cart.isEmpty ? null : _printReceipt,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C2C2C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.print, size: 20),
                          label: const Text('Print', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _cart.isEmpty ? null : _shareViaWhatsApp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.chat, size: 20),
                          label: const Text('WhatsApp', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<ProductItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.pink.shade50),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFFF0F5),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('GST: ${(item.gstRate * 100).toInt()}%', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Text(
                  '₹${item.defaultPrice.toInt()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFE91E63)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _addToCart(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF0F5),
                    foregroundColor: const Color(0xFFE91E63),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('+ Add', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
