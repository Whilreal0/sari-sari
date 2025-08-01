import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/store_bloc.dart';
import '../repository/store_repository.dart';
import '../components/store/store_info.dart';
import '../components/upgrade_dialog.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int selectedStoreIndex = 0;

  int getMaxStores(String plan) {
    if (plan == 'premium') return 3;
    if (plan == 'pro') return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        String plan = 'free';
        String userId = '';
        if (profileState is ProfileLoaded) {
          plan = profileState.plan;
          userId = profileState.profile['id'];
        }
        if (userId.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return BlocProvider(
          create: (_) => StoreBloc(StoreRepository())..add(FetchStores(userId)),
          child: BlocBuilder<StoreBloc, StoreState>(
            builder: (context, storeState) {
              List<Map<String, dynamic>> stores = [];
              if (storeState is StoreLoaded) {
                stores = storeState.stores;
              }
              int maxStores = getMaxStores(plan);
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Store'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Store',
                      onPressed: stores.length < maxStores
                          ? () async {
                              final nameController = TextEditingController();
                              final bloc = context.read<StoreBloc>(); // Capture bloc reference early
                              final result = await showDialog<String>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    'Add Store',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Store Name',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Theme.of(context).colorScheme.primary,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, nameController.text),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              );
                              if (result != null && result.isNotEmpty) {
                                if (!mounted) return;
                                bloc.add(AddStore(result, userId, plan: plan));
                                // Wait for the bloc to update before setting the index
                                await Future.delayed(const Duration(milliseconds: 100));
                                if (mounted) {
                                  setState(() {
                                    // Set to the last index (newly added store will be at the end)
                                    selectedStoreIndex = stores.length; // This will be the new store's index
                                  });
                                }
                              }
                            }
                          : null,
                    ),
                  ],
                ),
                body: SafeArea(
                  bottom: true,
                  child: storeState is StoreLoading
                      ? const Center(child: CircularProgressIndicator())
                      : storeState is StoreError
                          ? Center(child: Text(storeState.message))
                          : stores.isEmpty
                              ? const Center(child: Text('No stores found.'))
                              : Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          for (int i = 0; i < stores.length; i++)
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                child: GestureDetector(
                                                  onLongPress: i == 0 ? null : () async { // Disable long press for first store
                                                    final bloc = context.read<StoreBloc>(); // Capture bloc reference early
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text('Delete Store'),
                                                        content: Text('Are you sure you want to delete "${stores[i]['name'] ?? 'this store'}"?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context, false),
                                                            child: const Text('Cancel'),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () => Navigator.pop(context, true),
                                                            child: const Text('Delete'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm == true && mounted) {
                                                      bloc.add(DeleteStore(stores[i]['id'], userId));
                                                      setState(() {
                                                        if (selectedStoreIndex >= stores.length - 1 && selectedStoreIndex > 0) {
                                                          selectedStoreIndex--;
                                                        }
                                                      });
                                                    }
                                                  },
                                                  onDoubleTap: () async {
                                                    // Only allow renaming first store if premium, or any other store
                                                    if (i == 0 && plan != 'premium') {
                                                      if (mounted) {
                                                        UpgradeDialog.show(
                                                          context,
                                                          title: 'Premium Feature',
                                                          message: 'Rename your default store and unlock more customization options.',
                                                          requiredPlan: 'Premium',
                                                          onUpgrade: () {
                                                            Navigator.pop(context);
                                                            // TODO: Navigate to subscription page
                                                          },
                                                        );
                                                      }
                                                      return;
                                                    }
                                                    
                                                    final bloc = context.read<StoreBloc>(); // Capture bloc reference early
                                                    final nameController = TextEditingController(text: stores[i]['name']);
                                                    final result = await showDialog<String>(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text('Rename Store'),
                                                        content: TextField(
                                                          controller: nameController,
                                                          decoration: const InputDecoration(labelText: 'Store Name'),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context),
                                                            child: const Text('Cancel'),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () => Navigator.pop(context, nameController.text),
                                                            child: const Text('Rename'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (result != null && result.isNotEmpty && result != stores[i]['name'] && mounted) {
                                                      // Add rename functionality to StoreBloc
                                                      bloc.add(RenameStore(stores[i]['id'], result, userId));
                                                    }
                                                  },
                                                  child: ElevatedButton(
                                                    onPressed: () => setState(() => selectedStoreIndex = i),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: selectedStoreIndex == i
                                                          ? Theme.of(context).colorScheme.primary
                                                          : Colors.grey[200],
                                                      foregroundColor: selectedStoreIndex == i
                                                          ? Colors.white
                                                          : Theme.of(context).colorScheme.primary,
                                                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      elevation: selectedStoreIndex == i ? 2 : 0,
                                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                                    ),
                                                    child: Text(stores[i]['name'] ?? 'Store ${i + 1}'),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.only(bottom: 24),
                                        child: selectedStoreIndex < stores.length
                                            ? StoreInfo(
                                                storeNumber: selectedStoreIndex + 1,
                                                plan: plan,
                                                storeId: stores[selectedStoreIndex]['id'],
                                                adminId: userId,
                                              )
                                            : const Center(child: CircularProgressIndicator()),
                                      ),
                                    ),
                                  ],
                                ),
                ),
              );
            },
          ),
        );
      },
    );
  }
} 
