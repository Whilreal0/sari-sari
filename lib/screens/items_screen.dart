import 'package:flutter/material.dart';

// Mock user role (change to 'manager' to test restrictions)
const String userRole = 'admin';

// Mock item data
final List<Map<String, dynamic>> mockItems = [
  {
    'name': 'Softdrinks',
    'icon': Icons.local_drink,
    'iconColor': Colors.green,
    'price': 15,
    'stock': 3,
    'category': 'Drinks',
    'unit': 'Bottle',
    'minStock': 5,
  },
  {
    'name': 'Sardines',
    'icon': Icons.fastfood,
    'iconColor': Colors.blue,
    'price': 25,
    'stock': 0,
    'category': 'Canned',
    'unit': 'Can',
    'minStock': 5,
  },
  {
    'name': 'Chips',
    'icon': Icons.local_pizza,
    'iconColor': Colors.orange,
    'price': 10,
    'stock': 20,
    'category': 'Snacks',
    'unit': 'Pcs',
    'minStock': 5,
  },
];

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  String searchQuery = '';
  String? selectedCategory;
  String sortBy = 'Name';

  @override
  Widget build(BuildContext context) {
    // Filtered and sorted mock data
    List<Map<String, dynamic>> items = mockItems.where((item) {
      final matchesSearch = item['name'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == null || item['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
    if (sortBy == 'Name') {
      items.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (sortBy == 'Price') {
      items.sort((a, b) => a['price'].compareTo(b['price']));
    } else if (sortBy == 'Stock') {
      items.sort((a, b) => a['stock'].compareTo(b['stock']));
    }

    // Check for stock alerts
    final lowStockItems = items.where((item) => item['stock'] > 0 && item['stock'] < item['minStock']).toList();
    final outOfStockItems = items.where((item) => item['stock'] == 0).toList();

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddEditItemForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock alert banner (mock)
              if (lowStockItems.isNotEmpty || outOfStockItems.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lowStockItems.isNotEmpty)
                      ...lowStockItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text('⚠️ ${item['name']} is below minimum stock', style: const TextStyle(color: Colors.orange)),
                          ],
                        ),
                      )),
                    if (outOfStockItems.isNotEmpty)
                      ...outOfStockItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 18),
                            const SizedBox(width: 4),
                            Text('🔴 ${item['name']} is out of stock', style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      )),
                    const SizedBox(height: 8),
                  ],
                ),
              // Search bar
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search by name or barcode',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
              const SizedBox(height: 16),
              // Action buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showFilterDialog(context),
                    icon: const Icon(Icons.filter_list),
                    label: Text(selectedCategory ?? 'Filter'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _showSortDialog(context),
                    icon: const Icon(Icons.sort),
                    label: Text('Sort: $sortBy'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Item list
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No items found.'))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _ItemCard(
                            icon: item['icon'],
                            iconColor: item['iconColor'],
                            name: item['name'],
                            price: '₱${item['price']}',
                            stock: '${item['stock']} ${item['unit'].toString().toLowerCase() == 'pcs' ? 'pcs' : item['unit'].toLowerCase()}',
                            category: item['category'],
                            unit: item['unit'],
                            stockValue: item['stock'],
                            minStock: item['minStock'],
                            onEdit: () => _showAddEditItemForm(context, item: item),
                            onDelete: userRole == 'manager' ? null : () => _showDeleteDialog(context, item['name']),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final categories = mockItems.map((item) => item['category'] as String).toSet().toList();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('All Categories'),
              onTap: () {
                setState(() => selectedCategory = null);
                Navigator.pop(context);
              },
              selected: selectedCategory == null,
            ),
            ...categories.map((cat) => ListTile(
                  title: Text(cat),
                  onTap: () {
                    setState(() => selectedCategory = cat);
                    Navigator.pop(context);
                  },
                  selected: selectedCategory == cat,
                )),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final sorts = ['Name', 'Price', 'Stock'];
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: sorts
              .map((s) => ListTile(
                    title: Text(s),
                    onTap: () {
                      setState(() => sortBy = s);
                      Navigator.pop(context);
                    },
                    selected: sortBy == s,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showAddEditItemForm(BuildContext context, {Map<String, dynamic>? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
      child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item == null ? 'Add Item' : 'Edit Item', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                controller: TextEditingController(text: item?['name'] ?? ''),
              ),
              const SizedBox(height: 8),
              // Optional image picker placeholder
              Row(
        children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  const Text('Add Image (optional)'),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: item?['price']?.toString() ?? ''),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Stock quantity'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: item?['stock']?.toString() ?? ''),
              ),
              const SizedBox(height: 8),
              // Category dropdown (mock)
              DropdownButtonFormField<String>(
                value: item?['category'],
                items: mockItems.map((e) => e['category'] as String).toSet().map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (_) {},
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 8),
              // Unit dropdown (mock)
              DropdownButtonFormField<String>(
                value: item?['unit'],
                items: ['pcs', 'bottle', 'can', 'kg'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (_) {},
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              const SizedBox(height: 8),
              // Cost price (hidden for managers)
              if (userRole != 'manager')
                TextField(
                  decoration: const InputDecoration(labelText: 'Cost price (optional)'),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Save'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "$itemName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Mock: no actual delete
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name, price, stock, category, unit;
  final int stockValue, minStock;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _ItemCard({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.unit,
    required this.stockValue,
    required this.minStock,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color? stockColor;
    String? stockLabel;
    if (stockValue == 0) {
      stockColor = Colors.red;
      stockLabel = 'Out of stock';
    } else if (stockValue < minStock) {
      stockColor = Colors.orange;
      stockLabel = 'Only $stockValue left';
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (stockLabel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: stockColor!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      stockLabel,
                      style: TextStyle(color: stockColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Price: $price', style: TextStyle(color: Colors.grey[700])),
                const SizedBox(width: 16),
                Text('Stock: $stock', style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 4),
            Text('Category: $category', style: TextStyle(color: Colors.grey[600])),
            Text('Unit: $unit', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
                if (onDelete != null)
                  TextButton(
                    onPressed: onDelete,
                    child: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

