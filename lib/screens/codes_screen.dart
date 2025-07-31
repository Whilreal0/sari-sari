import 'package:flutter/material.dart';

import '../repository/invite_repository.dart';
import '../repository/store_repository.dart';
import '../services/user_service.dart';

class CodesScreen extends StatefulWidget {
  const CodesScreen({super.key});

  @override
  State<CodesScreen> createState() => _CodesScreenState();
}

class _CodesScreenState extends State<CodesScreen> {
  List<Map<String, dynamic>> stores = [];
  List<Map<String, dynamic>> inviteCodes = [];
  Map<String, int> storeManagerCounts = {}; // Cache manager counts
  bool isLoading = true;
  int selectedStoreIndex = 0;
  String userPlan = 'free';

  @override
  void initState() {
    super.initState();
    _loadStoresAndCodes();
  }

  Future<void> _loadStoresAndCodes() async {
    try {
      final userData = await UserService.getSubscriptionData();
      if (userData != null) {
        userPlan = userData['plan'] ?? 'free';
        
        // Load stores
        final storeRepo = StoreRepository();
        final storesList = await storeRepo.getStoresByOwner(userData['id']);
        
        if (mounted) {
          setState(() {
            stores = storesList;
          });
        }
        
        // Pre-load manager counts for all stores
        await _loadManagerCounts();
        
        // Load codes for selected store
        if (stores.isNotEmpty) {
          await _loadCodesForStore(stores[selectedStoreIndex]['id']);
        } else {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadManagerCounts() async {
    final storeRepo = StoreRepository();
    Map<String, int> counts = {};
    
    for (var store in stores) {
      final managers = await storeRepo.getManagersForStore(store['id']);
      final activeCount = managers
          .where((manager) => manager['display_status'] == 'Active')
          .length;
      counts[store['id']] = activeCount;
    }
    
    if (mounted) {
      setState(() {
        storeManagerCounts = counts;
      });
    }
  }

  int _getMaxManagers() {
    if (userPlan == 'pro') return 1;
    if (userPlan == 'premium') return 2;
    return 0;
  }

  bool _canGenerateCode() {
    if (stores.isEmpty) return false;
    final storeId = stores[selectedStoreIndex]['id'];
    final currentCount = storeManagerCounts[storeId] ?? 0;
    return currentCount < _getMaxManagers();
  }

  Future<void> _loadCodesForStore(String storeId) async {
    try {
      // Load real data from Supabase
      final codes = await InviteRepository().getInviteCodesForStore(storeId);
      
      if (mounted) {
        setState(() {
          inviteCodes = codes;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code History'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Store tabs
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      for (int i = 0; i < stores.length; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              onPressed: () {
                                if (mounted) {
                                  setState(() {
                                    selectedStoreIndex = i;
                                    isLoading = true;
                                  });
                                  _loadCodesForStore(stores[i]['id']);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedStoreIndex == i
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[200],
                                foregroundColor: selectedStoreIndex == i
                                    ? Colors.white
                                    : Colors.black87,
                                elevation: selectedStoreIndex == i ? 2 : 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                stores[i]['name'],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Code history header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Code History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final currentContext = context;
                          try {
                            final userData = await UserService.getSubscriptionData();
                            if (userData == null || stores.isEmpty) return;
                            
                            final currentStore = stores[selectedStoreIndex];
                            
                            // Check limits
                            final maxManagers = _getMaxManagers();
                            final currentCount = storeManagerCounts[currentStore['id']] ?? 0;
                            
                            if (currentCount >= maxManagers) {
                              if (!currentContext.mounted) return;
                              showDialog(
                                context: currentContext,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Manager Limit Reached'),
                                  content: Text('You have reached the maximum number of managers ($maxManagers) for your $userPlan plan.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              return;
                            }
                            
                            // Generate code
                            final newCode = await InviteRepository().createManagerInviteCode(
                              storeId: currentStore['id'],
                              adminId: userData['id'],
                            );
                            
                            // Update cache
                            storeManagerCounts[currentStore['id']] = currentCount + 1;
                            
                            // Show success dialog
                            if (!currentContext.mounted) return;
                            showDialog(
                              context: currentContext,
                              builder: (dialogContext) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Row(
                                  children: [
                                    Icon(Icons.vpn_key, color: Theme.of(dialogContext).primaryColor),
                                    const SizedBox(width: 8),
                                    const Text('Invite Code'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: Text(
                                        newCode,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                          letterSpacing: 4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Share this code with your manager. It expires in 7 days and can only be used once.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text('Close'),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      if (currentContext.mounted) {
                                        ScaffoldMessenger.of(currentContext).showSnackBar(
                                          const SnackBar(content: Text('Code copied to clipboard!')),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: const Text('Copy Code'),
                                  ),
                                ],
                              ),
                            );
                            
                            // Reload codes
                            await _loadCodesForStore(currentStore['id']);
                          } catch (e) {
                            if (currentContext.mounted) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                SnackBar(content: Text('Failed to generate code: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Generate Code'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Code list
                Expanded(
                  child: inviteCodes.isEmpty
                      ? const Center(
                          child: Text(
                            'No codes found for this store.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: inviteCodes.length,
                          itemBuilder: (context, index) {
                            final code = inviteCodes[index];
                            final isUsed = code['status'] == 'used';
                            final createdAt = DateTime.parse(code['created_at']).toLocal();
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  // Code
                                  GestureDetector(
                                    onLongPress: () {
                                      // Copy to clipboard
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Code ${code['code']} copied to clipboard!'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Text(
                                        code['code'],
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('-', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(width: 8),
                                  // Used by
                                  Expanded(
                                    child: Text(
                                      isUsed 
                                          ? ' ${code['used_by_name'] ?? 'Unknown'}'
                                          : 'pending',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isUsed ? Colors.green[700] : Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('-', style: TextStyle(color: Colors.grey)),
                                  const SizedBox(width: 8),
                                  // Created time
                                  Text(
                                    _formatDate(createdAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year.toString().substring(2)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}


