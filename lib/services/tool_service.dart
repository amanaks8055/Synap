import '../data/mock_data.dart';
import '../models/tool_model.dart';

class ToolService {
  static List<Tool> getAllTools() => MockData.tools;

  static List<Tool> getFeaturedTools() => MockData.getFeaturedTools();

  static List<Tool> getToolsByCategory(String categoryId) => MockData.getToolsByCategory(categoryId);

  static List<Tool> searchTools(String query) => MockData.searchTools(query);

  static List<Tool> filterTools({
    String? categoryId,
    String? query,
    bool? freeOnly,
  }) {
    var list = MockData.tools.toList();

    if (categoryId != null && categoryId != 'all') {
      list = list.where((t) => t.categoryId == categoryId).toList();
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((t) =>
        t.name.toLowerCase().contains(q) ||
        t.description.toLowerCase().contains(q)
      ).toList();
    }

    if (freeOnly == true) {
      list = list.where((t) => t.hasFreeTier).toList();
    }

    return list;
  }
}
