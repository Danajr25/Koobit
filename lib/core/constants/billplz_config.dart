/// Billplz payment gateway configuration.
///
/// Replace the placeholder values below with your real Billplz credentials
/// from https://www.billplz.com/enterprise/setting (or the sandbox dashboard).
///
/// IMPORTANT: In production, never call the Billplz API directly from the
/// client app — proxy through a Supabase Edge Function so the API key is
/// never shipped inside the APK/IPA.  For testing the UI flow this direct
/// approach is fine.
class BillplzConfig {
  BillplzConfig._();

  // ─────────────────────────────────────────────
  //  REPLACE THESE BEFORE GOING LIVE
  // ─────────────────────────────────────────────

  /// Your Billplz API key (found in Settings → API).
  static const String apiKey = 'YOUR_BILLPLZ_API_KEY';

  /// The collection ID that bills will be created under.
  static const String collectionId = 'YOUR_COLLECTION_ID';

  /// URL Billplz redirects to after the payer completes / cancels payment.
  /// Use a deep-link scheme your app handles, e.g. koobit://payment/return
  /// For testing just put any valid URL.
  static const String redirectUrl = 'https://koobit.com/payment/return';

  /// Webhook URL for Billplz server callbacks (handled by your backend).
  static const String callbackUrl = 'https://koobit.com/payment/callback';

  // ─────────────────────────────────────────────
  //  ENVIRONMENT
  // ─────────────────────────────────────────────

  /// Set to [false] when going live.
  static const bool sandbox = true;

  static String get baseUrl => sandbox
      ? 'https://www.billplz-sandbox.com/api/v3'
      : 'https://www.billplz.com/api/v3';

  // ─────────────────────────────────────────────
  //  PRICING  (RM, update to match your plans)
  // ─────────────────────────────────────────────

  static const double monthlyPriceRm = 19.90;
  static const double yearlyPriceRm = 149.00;

  /// Yearly saving expressed as a percentage vs 12 × monthly.
  static double get yearlySavingPct {
    final fullYearly = monthlyPriceRm * 12;
    return ((fullYearly - yearlyPriceRm) / fullYearly) * 100;
  }
}
