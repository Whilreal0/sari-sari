import 'package:flutter/material.dart';
import '../../repository/invite_repository.dart';
import '../../repository/store_repository.dart';

class StoreInfo extends StatelessWidget {
  final int storeNumber;
  final String plan;
  final String storeId;
  final String adminId;
  const StoreInfo({Key? key, required this.storeNumber, required this.plan, required this.storeId, required this.adminId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String storeName = 'Store $storeNumber';
    final String dateCreated = '2024-07-25';
    final String dailySales = '₱${(storeNumber * 1000).toStringAsFixed(2)}';
    final String weeklySales = '₱${(storeNumber * 5000).toStringAsFixed(2)}';
    final String monthlySales = '₱${(storeNumber * 20000).toStringAsFixed(2)}';
    int currentManagers = storeNumber == 1 ? 1 : storeNumber == 2 ? 0 : 2;
    int maxManagers = 0;
    String? upgradeText;
    if (plan == 'free') {
      maxManagers = 0;
      currentManagers = 0;
      upgradeText = 'Upgrade';
    } else if (plan == 'pro') {
      maxManagers = 1;
      currentManagers = 0;
      upgradeText = 'Upgrade';
    } else if (plan == 'premium') {
      maxManagers = 2;
      currentManagers = 2;
      upgradeText = null;
    }
    bool blurWeekly = plan == 'free';
    bool blurMonthly = plan == 'free' || plan == 'pro';
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
              Stack(
                children: [
                  Text(weeklySales, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(blurWeekly ? 0.3 : 1))),
                  if (blurWeekly)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withOpacity(0.5),
                        child: Center(
                          child: Text(
                            weeklySales,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black.withOpacity(0.15),
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_month, size: 16, color: Colors.purple[700]),
              const SizedBox(width: 6),
              Text('Monthly Sales: ', style: Theme.of(context).textTheme.bodyMedium),
              Stack(
                children: [
                  Text(monthlySales, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(blurMonthly ? 0.3 : 1))),
                  if (blurMonthly)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withOpacity(0.5),
                        child: Center(
                          child: Text(
                            monthlySales,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black.withOpacity(0.15),
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.group, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 6),
              Text('Managers: ', style: Theme.of(context).textTheme.bodyMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$currentManagers/$maxManagers', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
              ),
              if (upgradeText != null) ...[
                const SizedBox(width: 10),
                Icon(Icons.upgrade, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(upgradeText, style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.w500, fontSize: 12)),
              ],
            ],
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
                      try {
                        final inviteRepo = InviteRepository();
                        final inviteCode = await inviteRepo.createManagerInviteCode(
                          storeId: storeId,
                          adminId: adminId,
                        );
                        
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
                        if (inviteCodes.isNotEmpty) ...[
                          const Text('Invite Codes:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...inviteCodes.map((invite) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: invite['status'] == 'pending' ? Colors.orange[50] : Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: invite['status'] == 'pending' ? Colors.orange[200]! : Colors.green[200]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  invite['status'] == 'pending' ? Icons.schedule : Icons.check_circle,
                                  size: 16,
                                  color: invite['status'] == 'pending' ? Colors.orange[700] : Colors.green[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  invite['code'],
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    color: invite['status'] == 'pending' ? Colors.orange[800] : Colors.green[800],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(' - '),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: invite['status'] == 'pending' ? Colors.orange[100] : Colors.green[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    invite['status'] == 'pending' 
                                        ? 'pending' 
                                        : 'used by ${invite['used_by_name'] ?? 'Manager'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: invite['status'] == 'pending' ? Colors.orange[800] : Colors.green[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                          const SizedBox(height: 16),
                        ],
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
                                    (m['display_status'] ?? '') == 'Active' 
                                        ? 'Active' 
                                        : 'Pending',
                                    style: TextStyle(
                                      color: (m['display_status'] ?? '') == 'Active' 
                                          ? Colors.green[900] 
                                          : Colors.orange[900],
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 12
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
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
