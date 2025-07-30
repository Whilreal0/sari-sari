import 'package:flutter/material.dart';
import '../../repository/invite_repository.dart';
import '../../repository/store_repository.dart';

class StoreInfo extends StatelessWidget {
  final int storeNumber;
  final String plan;
  final String storeId;
  final String adminId;
  final String? createdAt; // Add this parameter
  
  const StoreInfo({
    Key? key, 
    required this.storeNumber, 
    required this.plan, 
    required this.storeId, 
    required this.adminId,
    this.createdAt, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String storeName = 'Store $storeNumber';
    final String dateCreated = createdAt != null 
        ? DateTime.parse(createdAt!).toLocal().toString().split(' ')[0]
        : DateTime.now().toString().split(' ')[0];
    final String dailySales = '₱${(storeNumber * 1000).toStringAsFixed(2)}';
    final String weeklySales = '₱${(storeNumber * 5000).toStringAsFixed(2)}';
    final String monthlySales = '₱${(storeNumber * 20000).toStringAsFixed(2)}';
    
    int maxManagers = 0;
    String? upgradeText;
    if (plan == 'free') {
      maxManagers = 0;
      upgradeText = 'Upgrade';
    } else if (plan == 'pro') {
      maxManagers = 1;
      upgradeText = 'Upgrade';
    } else if (plan == 'premium') {
      maxManagers = 2;
      upgradeText = null;
    }
    bool blurWeekly = plan == 'free';
    bool blurMonthly = plan != 'premium'; // Only show clearly for premium
    bool showManager = plan != 'free';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  storeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text('Daily Sales: $dailySales', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_view_week, size: 16, color: Colors.orange[700]),
              const SizedBox(width: 6),
              Text('Weekly Sales: ', style: Theme.of(context).textTheme.bodyMedium),
              Flexible(
                child: blurWeekly
                    ? GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Upgrade Required'),
                              content: const Text('Subscribe to Pro or Premium to view weekly sales.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock, size: 10, color: Colors.grey[600]),
                              const SizedBox(width: 2),
                              Text(
                                'Upgrade',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(weeklySales, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month, size: 16, color: Colors.purple[700]),
              const SizedBox(width: 6),
              Text('Monthly Sales: ', style: Theme.of(context).textTheme.bodyMedium),
              Flexible(
                child: blurMonthly
                    ? GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Upgrade Required'),
                              content: const Text('Subscribe to Premium to view monthly sales.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock, size: 10, color: Colors.grey[600]),
                              const SizedBox(width: 2),
                              Text(
                                'Upgrade',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Text(monthlySales, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: StoreRepository().getManagersForStore(storeId),
            builder: (context, snapshot) {
              int currentManagers = 0;
              if (snapshot.hasData) {
                // Count only active managers
                currentManagers = snapshot.data!
                    .where((manager) => manager['display_status'] == 'Active')
                    .length;
              }
              
              return Row(
                children: [
                  Icon(Icons.group, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 6),
                  Text('Managers: ', style: Theme.of(context).textTheme.bodyMedium),
                  if (plan == 'free')
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Upgrade Required'),
                            content: const Text('Subscribe to Pro or Premium to add managers.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock, size: 10, color: Colors.grey[600]),
                            const SizedBox(width: 2),
                            Text(
                              'Upgrade',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$currentManagers/$maxManagers', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text('Created: $dateCreated', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          if (showManager) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Managed by', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                if (plan == 'pro' || plan == 'premium')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.person_add, size: 16),
                    label: const Text('Generate Invite Code', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      // Check current manager count before generating code
                      final managers = await StoreRepository().getManagersForStore(storeId);
                      final currentManagers = managers
                          .where((manager) => manager['display_status'] == 'Active')
                          .length;
                      
                      if (!context.mounted) return;
                      
                      if (currentManagers >= maxManagers) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Manager Limit Reached'),
                            content: Text('You have reached the maximum number of managers ($maxManagers) for your $plan plan.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      
                      try {
                        final inviteRepo = InviteRepository();
                        final inviteCode = await inviteRepo.createManagerInviteCode(
                          storeId: storeId,
                          adminId: adminId,
                        );
                        
                        if (!context.mounted) return;
                        
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Manager Invite Code'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.vpn_key, size: 48, color: Colors.deepPurple),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    inviteCode,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Share this code with your manager. It expires in 7 days and can only be used once.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to generate code: $e')),
                        );
                      }
                    },
                  )
                else if (plan == 'free')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.lock, size: 16),
                    label: const Text('Add Manager', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Upgrade Required'),
                          content: const Text('Subscribe to Pro or Premium to add managers.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: StoreRepository().getManagersForStore(storeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Failed to load managers', style: TextStyle(color: Colors.red));
                }
                final managers = snapshot.data ?? [];
                
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: InviteRepository().getInviteCodesForStore(storeId),
                  builder: (context, inviteSnapshot) {
                    if (inviteSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final inviteCodes = inviteSnapshot.data ?? [];
                    
                    if (managers.isEmpty && inviteCodes.isEmpty) {
                      return const Text('No managers invited yet.', style: TextStyle(color: Colors.grey));
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (managers.isNotEmpty) ...[
                          const Text('Managers:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...managers.map((m) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 16, color: Colors.blue[700]),
                                const SizedBox(width: 6),
                                Text(m['full_name'] ?? m['email'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (m['display_status'] ?? '') == 'Active' 
                                        ? Colors.green[50] 
                                        : Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    m['display_status'] ?? 'Not Active',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: (m['display_status'] ?? '') == 'Active' 
                                          ? Colors.green[700] 
                                          : Colors.orange[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                        if (inviteCodes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('Pending Invites:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...inviteCodes.where((invite) => invite['status'] == 'pending').map((invite) => 
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule, size: 16, color: Colors.orange[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Code: ${invite['code']}',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
} 
