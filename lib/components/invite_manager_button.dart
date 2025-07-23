import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';

class InviteManagerButton extends StatelessWidget {
  const InviteManagerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        bool isEnabled = false;
        if (state is ProfileLoaded) {
          final plan = state.plan;
          isEnabled = plan == 'pro' || plan == 'premium';
        }
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.group_add),
            label: const Text('Invite'),
            onPressed: isEnabled
                ? () {
                    // TODO: Implement invite logic
                  }
                : () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Subscribe to invite managers.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: const TextStyle(fontSize: 16),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 0,
            ),
          ),
        );
      },
    );
  }
} 