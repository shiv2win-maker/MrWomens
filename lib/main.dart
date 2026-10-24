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
          seedColor: const Color(0xFFD81B60),
          primary: const Color(0xFFC2185B),
          secondary: const Color(0xFFE91E63),
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF7F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFAD1457),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const BillingHomePage(),
    );
  }
}

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

  List<Product> products = [
    Product(id: '1', name: '316L Anti-Tarnish Chain', category: 'Chains', price: 350),
    Product(id: '2', name: 'Micro Gold Plated Bangle', category: 'Bangles', price: 420),
    Product(id: '3', name: 'Stainless Steel Ring', category: 'Rings', price: 180),
    Product(id: '4', name: 'Korean Style Studs', category: 'Earrings', price: 120),
    Product(id: '5', name: 'Clover Bracelet', category: 'Bracelets', price: 290),
    Product(id: '6', name: 'Hair Claw Clip', category: 'Hair Accessories', price: 60),
  ];

  List<CartItem> cart = [];

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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC2185B),
                foregroundColor: Colors.white,
              ),
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
                        border: OutlineInputBorder(),
                        prefixText: '₹ ',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (existingProduct != null)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      setState(() {
                        products.removeWhere((p) => p.id == existingProduct.id);
                        cart.removeWhere((c) => c.product.id == existingProduct.id);
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Delete'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC2185B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    String name = nameCtrl.text.trim();
                    double? price = double.tryParse(priceCtrl.text);

                    if (name.isNotEmpty && price != null) {
                      setState(() {
                        if (existingProduct == null) {
                          products.add(Product(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: name,
                            category: prodCategory,
                            price: price,
                          ));
                        } else {
                          existingProduct.name = name;
                          existingProduct.category = prodCategory;
                          existingProduct.price = price;
                        }
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showCategoryManagerDialog() {
    TextEditingController newCatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Manage Categories'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newCatCtrl,
                            decoration: const InputDecoration(
                              labelText: 'New Category',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC2185B),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            String newCat = newCatCtrl.text.trim();
                            if (newCat.isNotEmpty && !categories.contains(newCat)) {
                              setState(() {
                                categories.add(newCat);
                              });
                              setDialogState(() {
                                newCatCtrl.clear();
                              });
                            }
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Existing Categories:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          String cat = categories[index];
                          if (cat == 'All') return const SizedBox.shrink();

                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(cat),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Color(0xFFC2185B)),
                                  onPressed: () {
                                    TextEditingController editCatCtrl =
                                        TextEditingController(text: cat);
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Edit Category'),
                                        content: TextField(
                                          controller: editCatCtrl,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFC2185B),
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              String updated = editCatCtrl.text.trim();
                                              if (updated.isNotEmpty) {
                                                setState(() {
                                                  categories[index] = updated;
                                                  for (var p in products) {
                                                    if (p.category == cat) {
                                                      p.category = updated;
                                                    }
                                                  }
                                                });
                                                setDialogState(() {});
                                              }
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text('Update'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      categories.removeAt(index);
                                      if (selectedCategory == cat) {
                                        selectedCategory = 'All';
                                      }
                                    });
                                    setDialogState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double get grandTotal {
    return cart.fold(0.0, (sum, item) => sum + item.total);
  }

  void copyBillText() {
    if (cart.isEmpty) return;

    StringBuffer buffer = StringBuffer();
    buffer.writeln('🌸 *Mr. Womens* 🌸');
    buffer.writeln('--------------------------------');
    for (var item in cart) {
      buffer.writeln(
          '${item.product.name}\n${item.quantity} x ₹${item.customPrice.toStringAsFixed(0)} = ₹${item.total.toStringAsFixed(0)}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('Grand Total: *₹${grandTotal.toStringAsFixed(0)}*');
    buffer.writeln('\nThank you! Visit Again!');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFFC2185B),
        content: Text('Bill copied! Ready to share on WhatsApp.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = products.where((p) {
      bool matchesCategory =
          selectedCategory == 'All' || p.category == selectedCategory;
      bool matchesSearch =
          p.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFFD54F),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Mr. Womens',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Manage Categories',
            onPressed: showCategoryManagerDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add Product',
            onPressed: () => showProductDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Cart',
            onPressed: () {
              if (cart.isNotEmpty) {
                setState(() => cart.clear());
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFC2185B)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF8BBD0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFF8BBD0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      setState(() => searchQuery = val);
                    },
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = cat == selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: const Color(0xFFF8BBD0),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF880E4F) : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => selectedCategory = cat);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text('No products found'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredProducts.length,
                          separatorBuilder: (context, i) =>
                              const Divider(height: 1, color: Color(0xFFFCE4EC)),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Card(
                              elevation: 0.5,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color(0xFFF8BBD0)),
                              ),
                              child: ListTile(
                                title: Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${product.category} • ₹${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Color(0xFFC2185B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                                      tooltip: 'Edit Product',
                                      onPressed: () =>
                                          showProductDialog(existingProduct: product),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFC2185B),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                      ),
                                      onPressed: () => addToCart(product),
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: Color(0xFFF8BBD0)),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                Container(
                  color: const Color(0xFFFCE4EC),
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cart Items',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF880E4F),
                        ),
                      ),
                      Text(
                        '${cart.length} items',
                        style: const TextStyle(color: Color(0xFFAD1457)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Cart is empty'))
                      : ListView.separated(
                          itemCount: cart.length,
                          separatorBuilder: (context, i) =>
                              const Divider(height: 1, color: Color(0xFFFCE4EC)),
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return ListTile(
                              dense: true,
                              title: Text(item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Row(
                                children: [
                                  InkWell(
                                    onTap: () => editCartPrice(item),
                                    child: Row(
                                      children: [
                                        Text(
                                          '₹${item.customPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: Color(0xFFC2185B),
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Icon(Icons.edit,
                                            size: 14, color: Color(0xFFC2185B)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Total: ₹${item.total.toStringAsFixed(0)}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        size: 20, color: Color(0xFFC2185B)),
                                    onPressed: () {
                                      setState(() {
                                        if (item.quantity > 1) {
                                          item.quantity--;
                                        } else {
                                          cart.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                  Text('${item.quantity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline,
                                        size: 20, color: Color(0xFFC2185B)),
                                    onPressed: () {
                                      setState(() {
                                        item.quantity++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF0F5),
                    border: Border(top: BorderSide(color: Color(0xFFF8BBD0))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Grand Total:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('₹${grandTotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFAD1457))),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC2185B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: cart.isEmpty ? null : copyBillText,
                          icon: const Icon(Icons.share),
                          label: const Text('Copy / WhatsApp Bill'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
