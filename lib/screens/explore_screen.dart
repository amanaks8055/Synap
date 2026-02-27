import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/premium/premium_bloc.dart';
import '../data/mock_data.dart';
import '../models/tool_model.dart';
import '../services/tool_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ad_banner.dart';
import '../widgets/tool_icon.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedChip = 'All';
  String _query = '';
  bool _freeOnly = false;

  List<String> get _chips => ['All', ...MockData.categories.map((c) => c.name)];

  List<Tool> get _filtered {
    final catId = _selectedChip == 'All' 
        ? null 
        : MockData.categories.firstWhere((c) => c.name == _selectedChip).id;
    
    return ToolService.filterTools(
      categoryId: catId,
      query: _query,
      freeOnly: _freeOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tools = _filtered;
    final premiumState = context.read<PremiumBloc>().state;
    final isPremium = premiumState.isPremium;

    // Build items list with ad placeholders every 6 items (free users)
    final items = <_ListItem>[];
    for (int i = 0; i < tools.length; i++) {
      if (!isPremium && i > 0 && i % 6 == 0) {
        items.add(_ListItem.ad());
      }
      items.add(_ListItem.tool(tools[i]));
    }

    return Scaffold(
      backgroundColor: SynapColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Center(child: Text('Explore', style: TextStyle(color: SynapColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700))),
            ),

            // Advanced Filter Toggle (Premium Only)
            if (isPremium)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    const Text('Free Only', style: TextStyle(color: SynapColors.textSecondary, fontSize: 13)),
                    const Spacer(),
                    SizedBox(
                      height: 24,
                      child: Switch(
                        value: _freeOnly,
                        onChanged: (v) => setState(() => _freeOnly = v),
                        activeColor: SynapColors.accent,
                      ),
                    ),
                  ],
                ),
              ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: SynapColors.bgSecondary, borderRadius: BorderRadius.circular(22)),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: SynapColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search AI tools...',
                    hintStyle: TextStyle(color: SynapColors.textMuted, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: SynapColors.textMuted, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8, runSpacing: 8,
                children: _chips.map((chip) {
                  final sel = _selectedChip == chip;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedChip = chip),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? SynapColors.accent.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? SynapColors.accent : SynapColors.border),
                      ),
                      child: Text(chip, style: TextStyle(
                        color: sel ? SynapColors.accent : SynapColors.textSecondary,
                        fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      )),
                    ),
                  );
                }).toList(),
              ),
            ),

            // List
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No tools found', style: TextStyle(color: SynapColors.textMuted)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        if (item.isAd) return const AdInlinePlaceholder();
                        return _buildToolTile(item.tool!);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolTile(Tool tool) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/toolDetail', arguments: tool),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: SynapColors.divider, width: 0.5))),
        child: Row(
          children: [
            ToolIcon(name: tool.name, categoryId: tool.categoryId),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tool.name, style: const TextStyle(color: SynapColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(tool.description, style: const TextStyle(color: SynapColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(border: Border.all(color: SynapColors.border), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      tool.hasFreeTier ? 'FREE' : 'PAID',
                      style: TextStyle(color: tool.hasFreeTier ? SynapColors.accentGreen : SynapColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: SynapColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

}

class _ListItem {
  final Tool? tool;
  final bool isAd;
  _ListItem._({this.tool, this.isAd = false});
  factory _ListItem.tool(Tool t) => _ListItem._(tool: t);
  factory _ListItem.ad() => _ListItem._(isAd: true);
}
