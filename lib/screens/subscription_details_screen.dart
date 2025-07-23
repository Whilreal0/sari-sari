import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Details')),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is ProfileLoaded) {
            final plan = state.plan;
            final start = state.profile['subscription_start'];
            final end = state.profile['subscription_end'];
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        plan == 'premium' ? Icons.workspace_premium : Icons.star,
                        color: plan == 'premium' ? Colors.amber : Colors.blue,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        plan[0].toUpperCase() + plan.substring(1),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: plan == 'premium' ? Colors.amber[800] : Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _DetailRow(label: 'Subscription Start', value: start != null ? start.toString().split(' ')[0] : '-'),
                  _DetailRow(label: 'Subscription Expiry', value: end != null ? end.toString().split(' ')[0] : '-'),
                  if (end != null)
                    _DetailRow(
                      label: 'Days Left',
                      value: (() {
                        final expiryDate = DateTime.tryParse(end);
                        if (expiryDate == null) return '-';
                        final daysLeft = expiryDate.difference(DateTime.now()).inDays;
                        return daysLeft >= 0 ? daysLeft.toString() : 'Expired';
                      })(),
                    ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
} 