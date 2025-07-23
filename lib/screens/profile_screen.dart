import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(LoadProfile()),
      child: SafeArea(
        bottom: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading || state is ProfileInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
              } else if (state is ProfileLoaded) {
                final profile = state.profile;
                final avatarUrl = profile['avatar_url'] ?? '';
                final role = profile['role'] ?? 'User';
                final fullName = profile['full_name'] ?? '';
                final number = profile['number'] ?? '';
                final email = profile['email'] ?? '';
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            Center(
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.deepPurple.shade100,
                                backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                                child: avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 48, color: Colors.deepPurple)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _ProfileRow(icon: Icons.verified_user, label: 'Role', value: role),
                            _ProfileRow(icon: Icons.person, label: 'Full Name', value: fullName),
                            _ProfileRow(icon: Icons.phone, label: 'Number', value: number),
                            _ProfileRow(icon: Icons.email, label: 'Email', value: email),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: Text(isEditing ? 'Update' : 'Edit'),
                        ),
                      ),
                    ),
                    if (isEditing)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text('Editing mode (UI only for now)', style: TextStyle(color: Colors.deepPurple)),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 