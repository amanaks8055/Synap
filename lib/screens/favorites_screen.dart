import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/favorites/favorites_bloc.dart';
import '../blocs/favorites/favorites_event.dart';
import '../blocs/favorites/favorites_state.dart';
import '../blocs/premium/premium_bloc.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_icon.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SynapColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Center(child: Text('Favorites', style: TextStyle(color: SynapColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700))),
            ),
            Expanded(
              child: BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, favState) {
                  final isPremium = context.read<PremiumBloc>().state.isPremium;

                  if (favState.favoriteIds.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border_rounded, size: 56, color: SynapColors.textMuted),
                          SizedBox(height: 16),
                          Text('No favorites yet', style: TextStyle(color: SynapColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 6),
                          Text('Tap ❤️ on any tool to save it here', style: TextStyle(color: SynapColors.textMuted, fontSize: 14)),
                        ],
                      ),
                    );
                  }

                  final tools = favState.favoriteIds
                      .map((id) => MockData.tools.where((t) => t.id == id))
                      .where((m) => m.isNotEmpty)
                      .map((m) => m.first)
                      .toList();

                  return Column(
                    children: [
                      if (!isPremium)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(color: SynapColors.bgSecondary, borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                const Icon(Icons.favorite_rounded, color: SynapColors.accent, size: 18),
                                const SizedBox(width: 10),
                                Text('${favState.favoriteIds.length} / ${favState.maxFree} saved', style: const TextStyle(color: SynapColors.textSecondary, fontSize: 13)),
                                const Spacer(),
                                if (favState.isAtFreeLimit)
                                  const Text('Upgrade for unlimited', style: TextStyle(color: SynapColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: tools.length,
                          separatorBuilder: (_, __) => const Divider(color: SynapColors.divider, height: 1),
                          itemBuilder: (context, i) {
                            final tool = tools[i];
                            return GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/toolDetail', arguments: tool),
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    ToolIcon(name: tool.name, categoryId: tool.categoryId, size: 44, fontSize: 18, radius: 12),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(tool.name, style: const TextStyle(color: SynapColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 2),
                                          Text(tool.hasFreeTier ? 'Free tier available' : 'Paid only', style: const TextStyle(color: SynapColors.textSecondary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.read<FavoritesBloc>().add(RemoveFavorite(tool.id)),
                                      child: const Icon(Icons.close_rounded, color: SynapColors.textMuted, size: 18),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
