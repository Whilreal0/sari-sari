import 'package:flutter/material.dart';
import 'manager_profile_screen.dart';

class ManagerButton extends StatelessWidget {
  const ManagerButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.group),
        label: const Text('Managers'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManagerScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontSize: 16),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
      ),
    );
  }
}

class ManagerScreen extends StatelessWidget {
  const ManagerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for managers - in real app, fetch from database
    final List<Map<String, String>> managers = [
      {
        'name': 'John Doe', 
        'startDate': '2024-05-01', 
        'avatar': '',
        'email': 'john@example.com'
      },
      {
        'name': 'Jane Smith', 
        'startDate': '2024-06-10', 
        'avatar': '',
        'email': 'jane@example.com'
      },
    ];
    
    // Mock current admin ID and store ID - get from actual auth/context
    const String currentAdminId = 'mock_admin_id';
    const String storeId = 'mock_store_id';
    
    return Scaffold(
      appBar: AppBar(title: const Text('Managers')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: managers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final manager = managers[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(manager['name'] ?? ''),
            subtitle: Text('Started: ${manager['startDate'] ?? ''}'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Theme.of(context).colorScheme.surface,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManagerProfileScreen(
                    name: manager['name'] ?? '',
                    avatar: manager['avatar'] ?? '',
                    startDate: manager['startDate'] ?? '',
                    email: manager['email'] ?? '',
                    storeId: storeId,
                    currentAdminId: currentAdminId,
                  ),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More Options',
              onPressed: () {
                // Show options menu
              },
            ),
          );
        },
      ),
    );
  }
} 
