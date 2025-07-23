import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';

class SubscriptionButton extends StatelessWidget {
  const SubscriptionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String buttonLabel = 'Upgrade Subscription';
        IconData buttonIcon = Icons.workspace_premium;
        Color? iconColor;
        // Match the profile button background color
        Color buttonColor = Theme.of(context).colorScheme.primary;
        Color textColor = Colors.white;
        VoidCallback? onPressed;

        if (state is ProfileLoaded) {
          final plan = state.plan;
          if (plan == 'premium' || plan == 'pro') {
            buttonLabel = plan[0].toUpperCase() + plan.substring(1);
            buttonIcon = plan == 'premium' ? Icons.workspace_premium : Icons.star;
            if (plan == 'premium') {
              iconColor = Colors.amber[700];
            } else if (plan == 'pro') {
              iconColor = Colors.blue;
            }
            buttonColor = Theme.of(context).colorScheme.primary;
            textColor = Colors.white;
            onPressed = () {
              Navigator.pushNamed(context, '/subscription-details');
            };
          } else {
            onPressed = () {
              // TODO: Implement upgrade logic
            };
          }
        } else {
          onPressed = () {
            // TODO: Implement upgrade logic
          };
        }

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(buttonIcon, color: iconColor),
            label: Text(buttonLabel),
            onPressed: onPressed,
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