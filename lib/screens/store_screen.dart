import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/store_bloc.dart';
import '../repository/store_repository.dart';
import '../components/store/store_info.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

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
        if (userId == null || userId.isEmpty) {
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
                              final result = await showDialog<String>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Add Store'),
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
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              );
                              if (result != null && result.isNotEmpty) {
                                context.read<StoreBloc>().add(AddStore(result, userId));
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
                                                    if (confirm == true) {
                                                      context.read<StoreBloc>().add(DeleteStore(stores[i]['id'], userId));
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
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text('Premium Required'),
                                                          content: const Text('Upgrade to Premium to rename the default store.'),
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
                                                    if (result != null && result.isNotEmpty && result != stores[i]['name']) {
                                                      // Add rename functionality to StoreBloc
                                                      context.read<StoreBloc>().add(RenameStore(stores[i]['id'], result, userId));
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
                                                    child: Text(stores[i]['name'] ?? 'Store  {i + 1}'),
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
