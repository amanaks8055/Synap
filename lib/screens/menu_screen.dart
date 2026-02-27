import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/premium/premium_bloc.dart';

import '../theme/app_theme.dart';
import '../widgets/tracker/tracker_home_widget.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SynapColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // Title (POE: centered)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Center(
                  child: Text('Menu', style: TextStyle(color: SynapColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                ),
              ),

              // ─── MENU ITEMS ──────────────────────
              BlocBuilder<PremiumBloc, PremiumState>(
                builder: (context, state) {
                  // Build menu items dynamically to avoid divider crash
                  final items = <Widget>[];

                  // Status: Tracker summary
                  items.add(const TrackerHomeWidget());
                  items.add(const SizedBox(height: 8));

                  if (!state.isPremium) {
                    items.add(_MenuItem(
                      icon: Icons.diamond_outlined,
                      title: 'Upgrade to Pro',
                      accent: true,
                      onTap: () => Navigator.pushNamed(context, '/premium'),
                    ));
                  }

                  items.add(_MenuItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Free Tier Tracker',
                    onTap: () => Navigator.pushNamed(context, '/tracker'),
                  ));

                  items.add(_MenuItem(
                    icon: Icons.mic_none_rounded,
                    title: 'Voice Hub',
                    onTap: () => Navigator.pushNamed(context, '/voice'),
                  ));

                  items.add(_MenuItem(
                    icon: Icons.shield_outlined,
                    title: 'Privacy Policy',
                    onTap: () => _openUrl(context, 'https://synap.app/privacy'),
                  ));

                  items.add(_MenuItem(
                    icon: Icons.mail_outline_rounded,
                    title: 'Contact',
                    onTap: () => _openUrl(context, 'mailto:contact@synap.app'),
                  ));

                  items.add(_MenuItem(
                    icon: Icons.star_outline_rounded,
                    title: 'Rate on Play Store',
                    onTap: () => _openUrl(context, 'https://play.google.com/store/apps/details?id=com.synap.synap'),
                  ));

                  items.add(_MenuItem(
                    icon: Icons.share_outlined,
                    title: 'Share App',
                    onTap: () => _openUrl(context, 'https://play.google.com/store/apps/details?id=com.synap.synap'),
                  ));

                  return _MenuGroup(children: items);
                },
              ),

              const SizedBox(height: 24),

              // App version
              const Text(
                'Synap v1.0.0',
                style: TextStyle(color: SynapColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        // CRASH PREVENTION: Check context is still valid after async gap
        if (!context.mounted) return;
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('⚠️ Could not open URL: $e');
    }
  }
}

// ─── REUSABLE MENU WIDGETS ────────────────────────
class _MenuGroup extends StatelessWidget {
  final List<Widget> children;
  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    // CRASH PREVENTION: Filter out empty/SizedBox widgets and handle empty list
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: SynapColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          children.length * 2 - 1,
          (i) {
            if (i.isOdd) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(color: SynapColors.divider, height: 1),
              );
            }
            return children[i ~/ 2];
          },
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool accent;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.title, this.accent = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: accent ? SynapColors.accent : SynapColors.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: accent ? SynapColors.accent : SynapColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: accent ? SynapColors.accent : SynapColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
