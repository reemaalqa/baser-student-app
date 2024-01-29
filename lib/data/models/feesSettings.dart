class FeesSettings {
  FeesSettings({
    required this.razorpayStatus,
    required this.razorpayApiKey,
    required this.stripeStatus,
    required this.stripePublishableKey,
    required this.currencyCode,
    required this.currencySymbol,
  });

  late final String razorpayStatus;
  late final String? razorpayApiKey;

  late final String stripeStatus;
  late final String stripePublishableKey;

  late final String currencyCode;
  late final String currencySymbol;

  FeesSettings.fromJson(Map<String, dynamic> json) {
    currencyCode = json['currency_code'] ?? "";
    currencySymbol = json['currency_symbol'] ?? "";
    razorpayStatus = json['razorpay_status'] ?? "0";
    stripeStatus = json['stripe_status'] ?? "0";
    razorpayApiKey = json['razorpay_api_key'] ?? "";
    stripePublishableKey = json['stripe_publishable_key'] ?? "";
  }
}
