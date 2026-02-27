// ══════════════════════════════════════════════════════════════
// SYNAP — Pricing Plans
// Student:      ₹29/2mo  | ₹79/7mo  | ₹549/yr
// Professional: ₹149/4mo | ₹749/yr
//
// ⚠️ These IDs must match EXACTLY what you create in Play Console
//    Go to: Play Console → Monetize → Subscriptions → Create
// ══════════════════════════════════════════════════════════════

class SynapPlans {
  // ── STUDENT TIER ────────────────────────────────────────
  static const String student2Month  = 'synap_student_2month';   // ₹29
  static const String student7Month  = 'synap_student_7month';   // ₹79
  static const String studentYearly  = 'synap_student_yearly';   // ₹549

  // ── PROFESSIONAL TIER ───────────────────────────────────
  static const String pro4Month      = 'synap_pro_4month';       // ₹149
  static const String proYearly      = 'synap_pro_yearly';       // ₹749

  // All product IDs for querying
  static const Set<String> allIds = {
    student2Month,
    student7Month,
    studentYearly,
    pro4Month,
    proYearly,
  };

  // Helper to check if a product ID is a Professional tier plan
  static bool isPro(String id) => id == pro4Month || id == proYearly;

  // Static plan definitions (shown before Play Store responds)
  static const List<PlanDefinition> studentPlans = [
    PlanDefinition(
      id: student2Month,
      tier: PlanTier.student,
      label: '2 Months',
      price: '₹29',
      priceValue: 29,
      period: '2 months',
      perMonth: '₹14.5/mo',
      highlight: null,
    ),
    PlanDefinition(
      id: student7Month,
      tier: PlanTier.student,
      label: '7 Months',
      price: '₹79',
      priceValue: 79,
      period: '7 months',
      perMonth: '₹11.3/mo',
      highlight: 'POPULAR',
    ),
    PlanDefinition(
      id: studentYearly,
      tier: PlanTier.student,
      label: '1 Year',
      price: '₹549',
      priceValue: 549,
      period: '1 year',
      perMonth: '₹45.8/mo',
      highlight: 'BEST VALUE',
    ),
  ];

  static const List<PlanDefinition> proPlans = [
    PlanDefinition(
      id: pro4Month,
      tier: PlanTier.professional,
      label: '4 Months',
      price: '₹149',
      priceValue: 149,
      period: '4 months',
      perMonth: '₹37.3/mo',
      highlight: null,
    ),
    PlanDefinition(
      id: proYearly,
      tier: PlanTier.professional,
      label: '1 Year',
      price: '₹749',
      priceValue: 749,
      period: '1 year',
      perMonth: '₹62.4/mo',
      highlight: 'BEST VALUE',
    ),
  ];
}

enum PlanTier { student, professional }

class PlanDefinition {
  final String id;
  final PlanTier tier;
  final String label;
  final String price;
  final double priceValue;
  final String period;
  final String perMonth;
  final String? highlight; // badge text

  const PlanDefinition({
    required this.id,
    required this.tier,
    required this.label,
    required this.price,
    required this.priceValue,
    required this.period,
    required this.perMonth,
    this.highlight,
  });

  bool get isStudent      => tier == PlanTier.student;
  bool get isProfessional => tier == PlanTier.professional;
}
