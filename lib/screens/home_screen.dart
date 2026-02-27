import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/mic_fab.dart';

import '../blocs/premium/premium_bloc.dart';
import '../data/mock_data.dart';
import '../models/tool_model.dart';
import '../theme/app_theme.dart';
import '../widgets/tool_icon.dart';
import 'category_tools_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SynapColors.bgPrimary,
      body: SafeArea(
        child: _query.isNotEmpty ? _buildSearchResults() : _buildHomeFeed(),
      ),
      floatingActionButton: MicFAB(
        onTap: () => Navigator.pushNamed(context, '/voice'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ─── HOME FEED ──────────────────────────────────
  Widget _buildHomeFeed() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildSection('Trending', MockData.getFeaturedTools()),
          ...MockData.categories.map((cat) {
            final tools = MockData.getToolsByCategory(cat.id);
            if (tools.isEmpty) return const SizedBox.shrink();
            return _buildSection(cat.name, tools, categoryId: cat.id);
          }),
          const SizedBox(height: 100), // Bottom padding for nav bar
        ],
      ),
    );
  }

  // ─── HEADER: icon + Synap + premium badge ───────
  Widget _buildHeader() {
    final isPremium = context.read<PremiumBloc>().state.isPremium;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SynapColors.accent.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: SynapColors.accent.withValues(alpha: 0.2), blurRadius: 10),
              ],
            ),
            child: SvgPicture.asset('assets/logo.svg'),
          ),
          const SizedBox(width: 10),
          const Text('Synap', style: TextStyle(color: SynapColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
          const Spacer(),
          if (!isPremium)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/premium'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SynapColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SynapColors.accent.withValues(alpha: 0.3)),
                ),
                child: const Text('PRO', style: TextStyle(color: SynapColors.accent, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
            ),
        ],
      ),
    );
  }

  // ─── SEARCH BAR ─────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: SynapColors.bgSecondary,
          borderRadius: BorderRadius.circular(22),
        ),
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
    );
  }

  // ─── SEARCH RESULTS ─────────────────────────────
  Widget _buildSearchResults() {
    final results = MockData.searchTools(_query);
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        Expanded(
          child: results.isEmpty
              ? const Center(child: Text('No tools found', style: TextStyle(color: SynapColors.textMuted)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(color: SynapColors.divider, height: 1),
                  itemBuilder: (_, i) {
                    final t = results[i];
                    return _SearchTile(tool: t, onTap: () {
                      Navigator.pushNamed(context, '/toolDetail', arguments: t);
                    });
                  },
                ),
        ),
      ],
    );
  }

  // ─── SECTION (horizontal scroll) ────────────────
  Widget _buildSection(String title, List<Tool> tools, {String? categoryId}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(color: SynapColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (categoryId != null)
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => CategoryToolsScreen(categoryId: categoryId, categoryName: title),
                  )),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Text('See all', style: TextStyle(color: SynapColors.accent, fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tools.length,
            itemBuilder: (_, i) => _HomeCard(tool: tools[i], onTap: () {
              Navigator.pushNamed(context, '/toolDetail', arguments: tools[i]);
            }),
          ),
        ),
      ],
    );
  }
}

// ─── HOME CARD (POE STYLE) ────────────────────────
class _HomeCard extends StatelessWidget {
  final Tool tool;
  final VoidCallback onTap;
  const _HomeCard({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Letter icon
            ToolIcon(name: tool.name, categoryId: tool.categoryId, size: 80, fontSize: 32, radius: 16),
            const SizedBox(height: 8),
            // Name — safe overflow
            Text(tool.name, style: const TextStyle(color: SynapColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            // Free/Paid badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: tool.hasFreeTier
                    ? SynapColors.accentGreen.withValues(alpha: 0.15)
                    : SynapColors.bgSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tool.hasFreeTier ? 'Free' : 'Paid',
                style: TextStyle(
                  color: tool.hasFreeTier ? SynapColors.accentGreen : SynapColors.textMuted,
                  fontSize: 9, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SEARCH TILE ──────────────────────────────────
class _SearchTile extends StatelessWidget {
  final Tool tool;
  final VoidCallback onTap;
  const _SearchTile({required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  Text(tool.description, style: const TextStyle(color: SynapColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
