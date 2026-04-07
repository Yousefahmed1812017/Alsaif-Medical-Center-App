import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Premium welcome header with gradient background, avatar, and greeting.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.user,
    required this.isArabic,
  });

  final UserModel user;
  final bool isArabic;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (isArabic) {
      if (hour < 12) return 'صباح الخير ☀️';
      if (hour < 17) return 'مساء الخير 🌤️';
      return 'مساء الخير 🌙';
    } else {
      if (hour < 12) return 'Good Morning ☀️';
      if (hour < 17) return 'Good Afternoon 🌤️';
      return 'Good Evening 🌙';
    }
  }

  dynamic _getRoleIcon() {
    switch (user.userType.toUpperCase()) {
      case 'DOCTOR':
        return FontAwesomeIcons.userDoctor;
      case 'ADMIN':
        return FontAwesomeIcons.userGear;
      default:
        return FontAwesomeIcons.userTie;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName(preferArabic: isArabic);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary700,
            AppColors.primary400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24,
            AppSpacing.s16,
            AppSpacing.s24,
            AppSpacing.s24,
          ),
          child: Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(40),
                    border: Border.all(
                      color: Colors.white.withAlpha(80),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: FaIcon(
                      _getRoleIcon(),
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s16),

              // Greeting + Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha(200),
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Notification bell
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(25),
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Notifications
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.bell,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
