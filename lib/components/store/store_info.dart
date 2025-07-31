import 'package:flutter/material.dart';
import '../../repository/invite_repository.dart';
import '../../repository/store_repository.dart';
import '../upgrade_dialog.dart';

class StoreInfo extends StatelessWidget {
  final int storeNumber;
  final String plan;
  final String storeId;
  final String adminId;
  final String? createdAt; // Add this parameter
  
  const StoreInfo({
    super.key, 
    required this.storeNumber, 
    required this.plan, 
    required this.storeId, 
    required this.adminId,
    this.createdAt,
  });

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
    if (plan == 'free') {
      maxManagers = 0;
    } else if (plan == 'pro') {
      maxManagers = 1;
    } else if (plan == 'premium') {
      maxManagers = 2;
    }
    bool blurWeekly = plan == 'free';
    bool blurMonthly = plan != 'premium'; // Only show clearly for premium
    bool showManager = plan != 'free';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha : 0.08),
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
                          UpgradeDialog.show(
                            context,
                            title: 'Unlock Weekly Analytics',
                            message: 'Get detailed weekly sales insights to track your business performance.',
                            requiredPlan: 'Pro',
                            onUpgrade: () {
                              Navigator.pop(context);
                              // TODO: Navigate to subscription page
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                          UpgradeDialog.show(
                            context,
                            title: 'Premium Analytics',
                            message: 'Access comprehensive monthly sales reports and advanced analytics.',
                            requiredPlan: 'Premium',
                            onUpgrade: () {
                              Navigator.pop(context);
                              // TODO: Navigate to subscription page
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
                        UpgradeDialog.show(
                          context,
                          title: 'Team Management',
                          message: 'Add managers to your stores and collaborate with your team.',
                          requiredPlan: 'Pro',
                          onUpgrade: () {
                            Navigator.pop(context);
                            // TODO: Navigate to subscription page
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
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
            Text('Managed by', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: StoreRepository().getManagersForStore(storeId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
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
                  );
                }
                
                return Column(
                  children: snapshot.data!.map((manager) => Container(
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
                      ],
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
} 
