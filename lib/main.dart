import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BillingApp(),
    ));

class Item {
  String name;
  String cat;
  double price;
  double gst;
  Item(this.name, this.cat, this.price, this.gst);
}

class CartRow {
  Item item;
  int qty;
  double price;
  CartRow(this.item, this.qty, this.price);
  double get total => price * qty;
}

class BillingApp extends StatefulWidget {
  const BillingApp({super.key});
  @override
  State<BillingApp> createState() => _BillingAppState();
}

class _BillingAppState extends State<BillingApp> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  final _name = TextEditingController();
  final _mob = TextEditingController();
  int billNo = 1042;
  final List<CartRow> cart = [];

  final List<Item> prods = [
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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  double get subTotal => cart.fold(0, (s, i) => s + i.total);
  double get grandTotal => cart.fold(0, (s, i) => s + (i.total * (1 + i.item.gst)));

  void add(Item it) {
    setState(() {
      int idx = cart.indexWhere((c) => c.item.name == it.name && c.item.cat == it.cat);
      if (idx >= 0) {
        cart[idx].qty++;
      } else {
        cart.add(CartRow(it, 1, it.price));
      }
    });
  }

  void newBill() {
    setState(() {
      billNo++;
      cart.clear();
      _name.clear();
      _mob.clear();
    });
  }

  void editPrice(int idx) {
    var c = TextEditingController(text: cart[idx].price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Price: ${cart[idx].item.name}'),
        content: TextField(controller: c, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              double? p = double.tryParse(c.text);
              if (p != null) setState(() => cart[idx].price = p);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  void sendWhatsApp() async {
    String msg = "*MR. WOMENS - BILL #$billNo*\n";
    msg += "Cust: ${_name.text.isEmpty ? 'Walk-in' : _name.text}\n";
    for (var i in cart) {
      msg += "${i.item.name} x${i.qty} = Rs.${i.total.toStringAsFixed(0)}\n";
    }
    msg += "*Total: Rs.${grandTotal.toStringAsFixed(2)}*\nThank you!";
    String u = "https://wa.me/91${_mob.text.trim()}?text=${Uri.encodeComponent(msg)}";
    await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
  }

  Future<void> printReceipt() async {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      pageFormat: const PdfPageFormat(58 * PdfPageFormat.mm, double.infinity, marginAll: 2 * PdfPageFormat.mm),
      build: (ctx) => pw.Column(
        children: [
          pw.Text('MR. WOMENS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.Text('Kangayam | Ph: 9600670996', style: const pw.TextStyle(fontSize: 7)),
          pw.Text('Bill: #$billNo | ${_name.text}', style: const pw.TextStyle(fontSize: 7)),
          pw.Divider(),
          ...cart.map((e) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${e.item.name} x${e.qty}', style: const pw.TextStyle(fontSize: 7)),
                  pw.Text('Rs.${e.total.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 7)),
                ],
              )),
          pw.Divider(),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
            pw.Text('Rs.${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
          ]),
        ],
      ),
    ));
    await Printing.layoutPdf(onLayout: (fmt) async => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('#$billNo', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 16)),
                    TextButton(onPressed: newBill, child: const Text('+ New Bill')),
                  ]),
                  Image.asset('logo.png', height: 45, errorBuilder: (c, e, s) => const Text('MR. WOMENS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink))),
                  const Text('Tirupur Road - Kangayam | Ph: 96006 70996', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: TextField(controller: _name, decoration: const InputDecoration(hintText: 'Customer Name', isDense: true))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _mob, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Mobile', isDense: true))),
                  ]),
                ],
              ),
            ),
            TabBar(controller: _tabs, indicatorColor: Colors.pink, labelColor: Colors.pink, tabs: const [
              Tab(text: 'Anti Tanishq'),
              Tab(text: 'Hair Accessories'),
              Tab(text: 'Kids'),
            ]),
            Expanded(
              child: TabBarView(controller: _tabs, children: [
                _buildList('Anti Tanishq'),
                _buildList('Hair Accessories'),
                _buildList('Kids'),
              ]),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: Column(
                children: [
                  ...cart.map((c) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${c.item.name} x${c.qty}'),
                          InkWell(
                            onTap: () => editPrice(cart.indexOf(c)),
                            child: Text('Rs.${c.total.toStringAsFixed(0)} (Edit)', style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
                          )
                        ],
                      )),
                  const Divider(),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Rs.${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.pink)),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: ElevatedButton(onPressed: cart.isEmpty ? null : printReceipt, child: const Text('Print'))),
                    const SizedBox(width: 8),
                    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), onPressed: cart.isEmpty ? null : sendWhatsApp, child: const Text('WhatsApp'))),
                  ])
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildList(String cat) {
    var items = prods.where((i) => i.cat == cat).toList();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, idx) => ListTile(
        title: Text(items[idx].name),
        subtitle: Text('Rs.${items[idx].price.toStringAsFixed(0)}'),
        trailing: ElevatedButton(onPressed: () => add(items[idx]), child: const Text('+ Add')),
      ),
    );
  }
}
