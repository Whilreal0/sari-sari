import 'package:flutter/material.dart';
import '../repository/invite_repository.dart';

class ManagerProfileScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final String startDate;
  final String email;
  final String storeId;
  final String currentAdminId;

  const ManagerProfileScreen({
    Key? key,
    required this.name,
    required this.avatar,
    required this.startDate,
    required this.email,
    required this.storeId,
    required this.currentAdminId,
  }) : super(key: key);

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  String? currentCode;
  bool isLoadingCode = false;

  Future<void> _generateNewCode() async {
    setState(() => isLoadingCode = true);
    
    try {
      final inviteRepo = InviteRepository();
      final newCode = await inviteRepo.regenerateManagerCode(
        widget.email,
        widget.storeId,
        widget.currentAdminId,
      );
      
      setState(() => currentCode = newCode);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New code generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate code: $e')),
      );
    } finally {
      setState(() => isLoadingCode = false);
    }
  }

  Future<void> _viewCurrentCode() async {
    setState(() => isLoadingCode = true);
    
    try {
      final inviteRepo = InviteRepository();
      final code = await inviteRepo.getCurrentManagerCode(
        widget.email,
        widget.storeId,
        widget.currentAdminId,
      );
      
      setState(() => currentCode = code);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get code: $e')),
      );
    } finally {
      setState(() => isLoadingCode = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manager Profile')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage: widget.avatar.isNotEmpty ? NetworkImage(widget.avatar) : null,
              child: widget.avatar.isEmpty ? const Icon(Icons.person, size: 32, color: Colors.deepPurple) : null,
            ),
          ),
          const SizedBox(height: 16),
          _ProfileRow(icon: Icons.person, label: 'Full Name', value: widget.name, compact: true),
          _ProfileRow(icon: Icons.email, label: 'Email', value: widget.email, compact: true),
          _ProfileRow(icon: Icons.calendar_today, label: 'Joined', value: widget.startDate, compact: true),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Manager Login Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    TextButton.icon(
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Code'),
                      onPressed: isLoadingCode ? null : _viewCurrentCode,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: isLoadingCode
                      ? const Center(child: CircularProgressIndicator())
                      : currentCode != null
                          ? Column(
                              children: [
                                Text(
                                  currentCode!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Share this code with the manager for login',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            )
                          : const Text(
                              'Click "View Code" to see the current login code',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Generate New Code'),
                    onPressed: isLoadingCode ? null : _generateNewCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Note: Generating a new code will invalidate the previous one',
                  style: TextStyle(fontSize: 11, color: Colors.orange),
                ),
              ],
            ),
          ),
          const Spacer(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    // Remove manager logic
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove Manager'),
                        content: Text('Are you sure you want to remove ${widget.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Remove manager logic here
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Remove', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Remove Manager', style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool compact;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 





