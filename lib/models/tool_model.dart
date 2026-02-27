class Tool {
  final String id;
  final String name;
  final String slug;
  final String categoryId;
  final String description;
  final String iconEmoji;
  final String iconUrl; // Real logo URL
  final String websiteUrl;
  final String? affiliateUrl;
  final bool hasFreeTier;
  final String? freeLimitDescription;
  final String? freeLimitDetails;
  final double? paidPriceMonthly;
  final double? paidPriceYearly;
  final String? paidTierDescription;
  final List<String> optimizationTips;
  final bool isFeatured;
  final bool isNew;
  final int clickCount;

  const Tool({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryId,
    required this.description,
    required this.iconEmoji,
    this.iconUrl = '',
    required this.websiteUrl,
    this.affiliateUrl,
    this.hasFreeTier = false,
    this.freeLimitDescription,
    this.freeLimitDetails,
    this.paidPriceMonthly,
    this.paidPriceYearly,
    this.paidTierDescription,
    this.optimizationTips = const [],
    this.isFeatured = false,
    this.isNew = false,
    this.clickCount = 0,
  });
}
