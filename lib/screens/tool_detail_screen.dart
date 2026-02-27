import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/favorites/favorites_bloc.dart';
import '../blocs/favorites/favorites_event.dart';
import '../blocs/favorites/favorites_state.dart';
import '../blocs/premium/premium_bloc.dart';
import '../models/tool_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner.dart';
import '../widgets/tool_icon.dart';

class ToolDetailScreen extends StatelessWidget {
  final Tool tool;
  const ToolDetailScreen({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SynapColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: SynapColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, state) {
                      final isFav = state.isFavorite(tool.id);
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? SynapColors.accentRed : SynapColors.textSecondary,
                        ),
                        onPressed: () {
                          final prem = context.read<PremiumBloc>().state;
                          if (!isFav && state.isAtFreeLimit && !prem.isPremium) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Free limit reached (5). Upgrade to Pro for unlimited.')),
                            );
                            return;
                          }
                          context.read<FavoritesBloc>().add(ToggleFavorite(tool.id));
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // ─── Content (scrollable) ──────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    ToolIcon(name: tool.name, categoryId: tool.categoryId, size: 90, fontSize: 40, radius: 22),
                    const SizedBox(height: 16),
                    Text(tool.name, style: const TextStyle(color: SynapColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(tool.description,
                      style: const TextStyle(color: SynapColors.textSecondary, fontSize: 14, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Free tier info — SAFE null check
                    if (tool.freeLimitDescription != null && tool.freeLimitDescription!.isNotEmpty)
                      _infoCard(
                        icon: tool.hasFreeTier ? Icons.check_circle_outline_rounded : Icons.lock_outline_rounded,
                        color: tool.hasFreeTier ? SynapColors.accentGreen : SynapColors.accentRed,
                        label: tool.hasFreeTier ? 'Free Tier' : 'Paid Only',
                        value: tool.freeLimitDescription!,
                      ),

                    // Pricing info — SAFE null check
                    if (tool.paidPriceMonthly != null && tool.paidPriceMonthly! > 0)
                      _infoCard(
                        icon: Icons.payments_outlined,
                        color: SynapColors.accent,
                        label: 'Pricing',
                        value: '\$${tool.paidPriceMonthly!.toStringAsFixed(0)}/month${tool.paidTierDescription != null ? ' — ${tool.paidTierDescription}' : ''}',
                      ),

                    // Optimization tips
                    if (tool.optimizationTips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _tipsCard(tool.optimizationTips),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ─── CTA Button ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: () => _openUrl(context, tool.websiteUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SynapColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Open Website', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),

            // ─── Banner ad (free users only) ───────
            // Uses StatefulWidget with proper initState/dispose
            BlocBuilder<PremiumBloc, PremiumState>(
              builder: (context, state) {
                if (state.isPremium) return const SizedBox(height: 16);
                return const AdBannerPlaceholder();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Info card widget ───────────────────────────
  Widget _infoCard({required IconData icon, required Color color, required String label, required String value}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: SynapColors.bgSecondary, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: SynapColors.textPrimary, fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tips card widget ───────────────────────────
  Widget _tipsCard(List<String> tips) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SynapColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SynapColors.accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: SynapColors.accent, size: 18),
              SizedBox(width: 8),
              Text('Optimization Tips', style: TextStyle(color: SynapColors.accent, fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  ', style: TextStyle(color: SynapColors.accent, fontSize: 14, fontWeight: FontWeight.w700)),
                Expanded(
                  child: Text(tip, style: const TextStyle(color: SynapColors.textPrimary, fontSize: 13, height: 1.4)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ─── URL launcher (safe + context.mounted check) ─
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
