import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/invite_repository.dart';
import '../bloc/profile_bloc.dart';
import '../repository/store_repository.dart';

class ManagerProfileScreen extends StatefulWidget {
  final String? name;
  final String? avatar;
  final String? startDate;
  final String? email;
  final String? storeId;
  final String? currentAdminId;

  const ManagerProfileScreen({
    super.key,
    this.name,
    this.avatar,
    this.startDate,
    this.email,
    this.storeId,
    this.currentAdminId,
  });

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  List<Map<String, dynamic>> stores = [];
  Map<String, List<Map<String, dynamic>>> storeManagers = {};
  bool isLoading = true;
  String currentAdminId = '';

  @override
  void initState() {
    super.initState();
    if (widget.name != null) {
      // Show individual manager profile
      _showIndividualProfile = true;
    } else {
      // Show stores and managers list
      _showIndividualProfile = false;
      _loadStoresAndManagers();
    }
  }

  bool _showIndividualProfile = false;

  Future<void> _loadStoresAndManagers() async {
    setState(() => isLoading = true);
    
    try {
      final profileState = context.read<ProfileBloc>().state;
      
      
      if (profileState is ProfileLoaded) {
        currentAdminId = profileState.profile['id'];
        
        
        final storeRepo = StoreRepository();
        final userStores = await storeRepo.getStoresByOwner(currentAdminId);
        
        
        Map<String, List<Map<String, dynamic>>> managersMap = {};
        
        for (var store in userStores) {
          final managers = await storeRepo.getManagersForStore(store['id']);
          
          managersMap[store['id']] = managers;
        }
        
        setState(() {
          stores = userStores;
          storeManagers = managersMap;
          isLoading = false;
        });
      } else {
        
        setState(() => isLoading = false);
      }
    } catch (e) {
      
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showIndividualProfile) {
      return _buildIndividualManagerProfile();
    } else {
      return _buildManagersList();
    }
  }

  Widget _buildManagersList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Managers'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stores.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No stores found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: stores.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 32),
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    final managers = storeManagers[store['id']] ?? [];
                    
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.store,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                store['name'] ?? 'Store ${index + 1}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (managers.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.person_off_outlined, color: Colors.grey[600], size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'No managers assigned',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...managers.map((manager) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: manager['display_status'] == 'Active' 
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: manager['display_status'] == 'Active' 
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.orange.withValues(alpha: 0.2),
                                    child: Icon(
                                      Icons.person,
                                      size: 16,
                                      color: manager['display_status'] == 'Active' 
                                          ? Colors.green[700]
                                          : Colors.orange[700],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      manager['full_name'] ?? manager['email'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: manager['display_status'] == 'Active' 
                                          ? Colors.green
                                          : Colors.orange,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      manager['display_status'] ?? 'Pending',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Container(
                                    margin: const EdgeInsets.only(right: 0),
                                    child: PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          // TODO: Implement delete functionality
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Remove Manager'),
                                              content: Text('Are you sure you want to remove ${manager['full_name'] ?? manager['email']}?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    // TODO: Add actual delete logic here
                                                  },
                                                  child: const Text('Remove', style: TextStyle(color: Colors.red)),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                              SizedBox(width: 4),
                                              Text('Delete', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                      icon: const Icon(Icons.more_vert, size: 16, color: Colors.grey),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                      splashRadius: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildIndividualManagerProfile() {
    String? currentCode;
    bool isLoadingCode = false;

    Future<void> generateNewCode() async {
      setState(() => isLoadingCode = true);
      
      try {
        final inviteRepo = InviteRepository();
        final newCode = await inviteRepo.regenerateManagerCode(
          widget.email!,
          widget.storeId!,
          widget.currentAdminId!,
        );
        
        setState(() => currentCode = newCode);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New code generated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to generate code: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoadingCode = false);
        }
      }
    }

    Future<void> viewCurrentCode() async {
      setState(() => isLoadingCode = true);
      
      try {
        final inviteRepo = InviteRepository();
        final code = await inviteRepo.getCurrentManagerCode(
          widget.email!,
          widget.storeId!,
          widget.currentAdminId!,
        );
        
        setState(() => currentCode = code);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get code: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => isLoadingCode = false);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manager Profile')),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage: widget.avatar!.isNotEmpty ? NetworkImage(widget.avatar!) : null,
              child: widget.avatar!.isEmpty ? const Icon(Icons.person, size: 32, color: Colors.deepPurple) : null,
            ),
          ),
          const SizedBox(height: 16),
          _ProfileRow(icon: Icons.person, label: 'Full Name', value: widget.name!, compact: true),
          _ProfileRow(icon: Icons.email, label: 'Email', value: widget.email!, compact: true),
          _ProfileRow(icon: Icons.calendar_today, label: 'Joined', value: widget.startDate!, compact: true),
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
                      onPressed: isLoadingCode ? null : viewCurrentCode,
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
                    onPressed: isLoadingCode ? null : generateNewCode,
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
                        content: Text('Are you sure you want to remove ${widget.name!}?'),
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




































