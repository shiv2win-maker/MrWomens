
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const BillingApp());
}

class Item {
  final String name;
  final String cat;
  final double price;
  final double gst;

  const Item(this.name, this.cat, this.price, this.gst);
}

class CartRow {
  final Item item;
  int qty;
  double price;

  CartRow(this.item, this.qty, this.price);

  double get total => price * qty;
  double get tax => total * item.gst;
  double get netTotal => total + tax;
}

class BillingApp extends StatefulWidget {
  const BillingApp({super.key});

  @override
  State<BillingApp> createState() => _BillingAppState();
}

class _BillingAppState extends State<BillingApp>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final _name = TextEditingController();
  final _mob = TextEditingController();

  int billNo = 1042;
  final List<CartRow> cart = [];

  final List<Item> prods = const [
    Item('Kada', 'Anti Tanishq', 1000, 0.03),
    Item('Ring', 'Anti Tanishq', 250, 0.03),
    Item('Bangles', 'Anti Tanishq', 600, 0.03),
    Item('Chain', 'Anti Tanishq', 750, 0.03),
    Item('Watch', 'Anti Tanishq', 1200, 0.03),
    Item('Bracelet', 'Anti Tanishq', 350, 0.03),
    Item('Anklet', 'Anti Tanishq', 500, 0.03),
    Item('Normal Clips', 'Hair Accessories', 50, 0.12),
    Item('Premium Clips', 'Hair Accessories', 120, 0.12),
    Item('Bands', 'Hair Accessories', 30, 0.12),
    Item('Accessories', 'Hair Accessories', 80, 0.12),
    Item('Kids Watch', 'Kids', 250, 0.18),
    Item('Kids Bag', 'Kids', 450, 0.18),
    Item('Keychains', 'Kids', 80, 0.18),
    Item('Accessories', 'Kids', 150, 0.18),
  ];

  String selectedCategory = 'All';

  final List<String> categories = const [
    'All',
    'Anti Tanishq',
    'Hair Accessories',
    'Kids',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _name.dispose();
    _mob.dispose();
    super.dispose();
  }

  double get subTotal =>
      cart.fold(0.0, (sum, row) => sum + row.total);

  double get totalGST =>
      cart.fold(0.0, (sum, row) => sum + row.tax);

  double get grandTotal =>
      cart.fold(0.0, (sum, row) => sum + row.netTotal);

  String money(double value) =>
      NumberFormat.currency(
        locale: 'en_IN',
        symbol: '₹',
        decimalDigits: 2,
      ).format(value);

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void add(Item item) {
    setState(() {
      final index = cart.indexWhere(
        (row) =>
            row.item.name == item.name &&
            row.item.cat == item.cat,
      );

      if (index >= 0) {
        cart[index].qty++;
      } else {
        cart.add(CartRow(item, 1, item.price));
      }
    });

    showMessage('${item.name} added to bill');
  }

  void changeQty(int index, int change) {
    setState(() {
      cart[index].qty += change;

      if (cart[index].qty <= 0) {
        cart.removeAt(index);
      }
    });
  }

  void removeItem(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  void newBill() {
    if (cart.isEmpty &&
        _name.text.isEmpty &&
        _mob.text.isEmpty) {
      showMessage('New bill is ready');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start New Bill?'),
        content: const Text(
          'The current bill will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                billNo++;
                cart.clear();
                _name.clear();
                _mob.clear();
              });

              Navigator.pop(dialogContext);
              showMessage('New bill #$billNo created');
            },
            child: const Text('New Bill'),
          ),
        ],
      ),
    );
  }

  void editPrice(int index) {
    final controller = TextEditingController(
      text: cart[index].price.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit ${cart[index].item.name} Price'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Price (₹)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text.trim());

              if (price == null ||
                  !price.isFinite ||
                  price < 0) {
                showMessage('Enter a valid price');
                return;
              }

              setState(() {
                cart[index].price = price;
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> sendWhatsApp() async {
    if (cart.isEmpty) {
      showMessage('Please add products first');
      return;
    }

    final phone = _mob.text.replaceAll(
      RegExp(r'[\s+\-()]'),
      '',
    );

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      showMessage('Enter a valid 10-digit mobile number');
      return;
    }

    final buffer = StringBuffer();

    buffer.writeln('*MR. WOMENS*');
    buffer.writeln('Bill No: #$billNo');
    buffer.writeln(
      'Date: ${DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now())}',
    );
    buffer.writeln(
      'Customer: ${_name.text.trim().isEmpty ? 'Walk-in' : _name.text.trim()}',
    );
    buffer.writeln('');
    buffer.writeln('*ITEMS*');

    for (final row in cart) {
      buffer.writeln(
        '${row.item.name} x ${row.qty} = ${money(row.total)}',
      );
    }

    buffer.writeln('');
    buffer.writeln('Subtotal: ${money(subTotal)}');
    buffer.writeln('GST: ${money(totalGST)}');
    buffer.writeln('*Grand Total: ${money(grandTotal)}*');
    buffer.writeln('');
    buffer.writeln('Thank you for shopping with us!');

    final uri = Uri.https(
      'wa.me',
      '/91$phone',
      {'text': buffer.toString()},
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        showMessage('Could not open WhatsApp');
      }
    } catch (e) {
      if (mounted) {
        showMessage('Unable to open WhatsApp');
      }
    }
  }

  Future<void> printReceipt() async {
    if (cart.isEmpty) {
      showMessage('Please add products first');
      return;
    }

    final doc = pw.Document();

    final date = DateFormat(
      'dd-MM-yyyy hh:mm a',
    ).format(DateTime.now());

    doc.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          58 * PdfPageFormat.mm,
          220 * PdfPageFormat.mm,
          marginAll: 2 * PdfPageFormat.mm,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  'MR. WOMENS',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Center(
                child: pw.Text(
                  'Kangayam | Ph: 9600670996',
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Bill No: #$billNo',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'Customer: ${_name.text.trim().isEmpty ? 'Walk-in' : _name.text.trim()}',
                style: const pw.TextStyle(fontSize: 7),
              ),
              pw.Text(
                'Date: $date',
                style: const pw.TextStyle(fontSize: 7),
              ),
              pw.Divider(),

              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      'Item',
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'Qty',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Amount',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 7,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              pw.Divider(),

              ...cart.map(
                (row) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(
                          row.item.name,
                          style: const pw.TextStyle(fontSize: 7),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '${row.qty}',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 7),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          row.total.toStringAsFixed(2),
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.Divider(),

              _pdfTotal('Subtotal', subTotal),
              _pdfTotal('GST', totalGST),

              pw.Divider(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'GRAND TOTAL',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Rs. ${grandTotal.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              pw.Center(
                child: pw.Text(
                  'Thank You! Visit Again',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
      );
    } catch (e) {
      if (mounted) {
        showMessage('Unable to print receipt');
      }
    }
  }

  pw.Widget _pdfTotal(String label, double value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            'Rs. ${value.toStringAsFixed(2)}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _productCard(Item item) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 30,
              color: Colors.deepPurple,
            ),
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              item.cat,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
            Text(
              money(item.price),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => add(item),
                icon: const Icon(Icons.add_shopping_cart, size: 16),
                label: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _billingTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BILL #$billNo',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _mob,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp Number',
                    prefixIcon: Icon(Icons.phone_android),
                    prefixText: '+91 ',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bill Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('${cart.length} products'),
          ],
        ),

        if (cart.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 55,
                  color: Colors.grey,
                ),
                SizedBox(height: 8),
                Text('No items added yet'),
                Text('Open Products and tap Add'),
              ],
            ),
          ),

        ...List.generate(cart.length, (index) {
          final row = cart[index];

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${money(row.price)} each',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'GST ${(row.item.gst * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit price',
                        onPressed: () => editPrice(index),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Remove item',
                        onPressed: () => removeItem(index),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () => changeQty(index, -1),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '${row.qty}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => changeQty(index, 1),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      const Spacer(),
                      Text(
                        money(row.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 8),

        _totalsCard(),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child
