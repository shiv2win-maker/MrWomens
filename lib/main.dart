import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  double price;
  final double gstRate;

  ProductItem({
    required this.name,
    required this.category,
    required this.price,
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
    ProductItem(name: 'Kada', category: 'Anti Tanishq', price: 1000, gstRate: 0.03),
    ProductItem(name: 'Ring', category: 'Anti Tanishq', price: 250, gstRate: 0.03),
    ProductItem(name: 'Bangles', category: 'Anti Tanishq', price: 600, gstRate: 0.03),
    ProductItem(name: 'Chain', category: 'Anti Tanishq', price: 750, gstRate: 0.03),
    ProductItem(name: 'Watch', category: 'Anti Tanishq', price: 1200, gstRate: 0.03),
    ProductItem(name: 'Bracelet', category: 'Anti Tanishq', price: 350, gstRate: 0.03),
    ProductItem(name: 'Anklet', category: 'Anti Tanishq', price: 500, gstRate: 0.03),
  ];

  final List<ProductItem> hairAccessories = [
    ProductItem(name: 'Normal Clips', category: 'Hair Accessories', price: 50, gstRate: 0.12),
    ProductItem(name: 'Premium Clips', category: 'Hair Accessories', price: 120, gstRate: 0.12),
    ProductItem(name: 'Bands', category: 'Hair Accessories', price: 30, gstRate: 0.12),
    ProductItem(name: 'Accessories', category: 'Hair Accessories', price: 80, gstRate: 0.12),
  ];

  final List<ProductItem> kidsItems = [
    ProductItem(name: 'Kids Watch', category: 'Kids', price: 250, gstRate: 0.18),
    ProductItem(name: 'Kids Bag', category: 'Kids', price: 450, gstRate: 0.18),
    ProductItem(name: 'Keychains', category: 'Kids', price: 80, gstRate: 0.18),
    ProductItem(name: 'Accessories', category: 'Kids', price: 150, gstRate: 0.18),
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
        _cart.add(CartItem(product: item, price: item.price, quantity: 1));
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

  void _editItemPriceDialog(int cartIndex) {
    final controller = TextEditingController(text: _cart[cartIndex].price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Price: ${_cart[cartIndex].product.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Price (₹)', prefixText: '₹'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text) ?? _cart[cartIndex].price;
              setState(() {
                _cart[cartIndex].price = newPrice;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _resetForNewBill() {
    setState(() {
      billNumber += 1;
      _cart.clear();
      _nameController.clear();
      _mobileController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Started New Bill #$billNumber')),
    );
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
    buffer.writeln("*MR. WOMENS*");
    buffer.writeln("Tirupur Road - Kangayam");
    buffer.writeln("GSTIN: 33GHWPS6754J1ZA");
    buffer.writeln("Contact: +91 96006 70996");
    buffer.writeln("================================");
    buffer.writeln("Customer: ${_nameController.text.isEmpty ? 'Customer' : _nameController.text}   $dateStr");
    buffer.writeln("Mobile  : ${_mobileController.text.isEmpty ? '-' : _mobileController.text}   $timeStr");
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

    final encodedText = Uri.encodeComponent(buffer.toString());
    final phone = _mobileController.text.trim().replaceAll(RegExp(r'\D'), '');

    final whatsappUrl = phone.isNotEmpty
        ? Uri.parse("whatsapp://send?phone=91$phone&text=$encodedText")
        : Uri.parse("whatsapp://send?text=$encodedText");

    final webFallback = phone.isNotEmpty
        ? Uri.parse("https://api.whatsapp.com/send?phone=91$phone&text=$encodedText")
        : Uri.parse("https://api.whatsapp.com/send?text=$encodedText");

    try {
      final launched = await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(webFallback, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      await launchUrl(webFallback, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _printDirectToBluetooth() async {
    final now = DateTime.now();
    final dateStr = DateFormat('dd-MM-yyyy').format(now);
    final timeStr = DateFormat('hh:mm a').format(now);

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity, marginAll: 2 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Align(alignment: pw.Alignment.topLeft, child: pw.Text('#$billNumber', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
              pw.Text('MR. WOMENS', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('Tirupur Road - Kangayam', style: const pw.TextStyle(fontSize: 7)),
              pw.Text('GSTIN: 33GHWPS6754J1ZA', style: const pw.TextStyle(fontSize: 7)),
              pw.Text('Contact: +91 96006 70996', style: const pw.TextStyle(fontSize: 7)),
              pw.Divider(thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Cust: ${_nameController.text.isEmpty ? "Walk-in" : _nameController.text}', style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(dateStr, style: const pw.TextStyle(fontSize: 7)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Mob: ${_mobileController.text}', style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(timeStr, style: const pw.TextStyle(fontSize: 7)),
                ],
              ),
              pw.Divider(thickness: 0.5),
              ..._cart.map(
                (item) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text('${item.product.name} (x${item.quantity})', style: const pw.TextStyle(fontSize: 7))),
                      pw.Text('₹${item.total.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 7)),
                    ],
                  ),
                ),
              ),
              pw.Divider(thickness: 0.5),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Sub Total:', style: const pw.TextStyle(fontSize: 7)), pw.Text('₹${subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 7))]),
              if (gstAntiTanishq > 0) pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('GST 3%:', style: const pw.TextStyle(fontSize: 6)), pw.Text('₹${gstAntiTanishq.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 6))]),
              if (gstHairAcc > 0) pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('GST 12%:', style: const pw.TextStyle(fontSize: 6)), pw.Text('₹${gstHairAcc.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 6))]),
              if (gstKids > 0) pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('GST 18%:', style: const pw.TextStyle(fontSize: 6)), pw.Text('₹${gstKids.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 6))]),
              pw.SizedBox(height: 2),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('GRAND TOTAL:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)), pw.Text('₹${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))]),
              pw.Divider(thickness: 0.5),
              pw.Text('Thank you! Visit again!', style: const pw.TextStyle(fontSize: 6)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  Widget _buildProductGrid(List<ProductItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final priceController = TextEditingController(text: item.price.toStringAsFixed(0));

        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.pink.shade50),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFFFF0F5),
                  child: Text('${index + 1}', style: const TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  width: 75,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFE91E63)),
                    decoration: InputDecoration(
                      prefixText: '₹',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) {
                        item.price = parsed;
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _addToCart(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF0F5),
                    foregroundColor: const Color(0xFFE91E63),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    
