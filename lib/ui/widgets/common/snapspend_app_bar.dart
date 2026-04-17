import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/settings_viewmodel.dart';

class SnapSpendAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfile;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLogoPressed;
  final bool showBackButton;

  const SnapSpendAppBar({
    super.key,
    this.title = 'SnapSpend',
    this.showProfile = true,
    this.onProfilePressed,
    this.onLogoPressed,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBackButton
        ? IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.maybePop(context),
          )
        : null,
      titleSpacing: showBackButton ? 0 : 16,
      title: InkWell(
        onTap: onLogoPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.headlineMedium,
            ),
          ],
        ),
      ),
      actions: [
        if (showProfile)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: onProfilePressed,
              borderRadius: BorderRadius.circular(18),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  settings.userName.isNotEmpty
                      ? settings.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
