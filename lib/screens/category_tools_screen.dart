import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/tool_model.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_icon.dart';

class CategoryToolsScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  const CategoryToolsScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final tools = MockData.getToolsByCategory(categoryId);
    return Scaffold(
      backgroundColor: SynapColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back_rounded, color: SynapColors.textPrimary), onPressed: () => Navigator.pop(context)),
                Text(categoryName, style: const TextStyle(color: SynapColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
              ]),
            ),
            Expanded(
              child: tools.isEmpty
                  ? const Center(child: Text('No tools in this category', style: TextStyle(color: SynapColors.textMuted)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: tools.length,
                      separatorBuilder: (_, __) => const Divider(color: SynapColors.divider, height: 1),
                      itemBuilder: (context, i) => _tile(context, tools[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, Tool tool) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/toolDetail', arguments: tool),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          ToolIcon(name: tool.name, categoryId: tool.categoryId),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tool.name, style: const TextStyle(color: SynapColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(tool.description, style: const TextStyle(color: SynapColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(border: Border.all(color: SynapColors.border), borderRadius: BorderRadius.circular(6)),
              child: Text(tool.hasFreeTier ? 'FREE' : 'PAID', style: TextStyle(color: tool.hasFreeTier ? SynapColors.accentGreen : SynapColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ])),
          const Icon(Icons.chevron_right_rounded, color: SynapColors.textMuted, size: 20),
        ]),
      ),
    );
  }
}
