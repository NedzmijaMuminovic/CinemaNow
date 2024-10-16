import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:cinemanow_mobile/providers/base_provider.dart';

class PaymentProvider extends BaseProvider {
  PaymentProvider() : super("Payment");

  Future<Map<String, dynamic>> createPaymentIntent(int amountInCents) async {
    var url = "$baseUrl$endpoint/create-payment-intent";
    var uri = Uri.parse(url);

    var headers = createHeaders();

    var response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'amount': amountInCents}),
    );

    if (isValidResponse(response)) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create payment intent: ${response.body}');
    }
  }

  Future<void> initializePaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        style: ThemeMode.dark,
        merchantDisplayName: 'Cinema Now',
        appearance: PaymentSheetAppearance(
          colors: PaymentSheetAppearanceColors(
            background: Colors.grey[900],
            componentBackground: Colors.grey[800],
            primary: Colors.red,
            componentText: Colors.white,
            secondaryText: Colors.grey[300],
            placeholderText: Colors.grey[500],
            icon: Colors.white,
            primaryText: Colors.white,
          ),
          shapes: PaymentSheetShape(
            borderRadius: 12,
            shadow:
                PaymentSheetShadowParams(color: Colors.black.withOpacity(0.5)),
          ),
          primaryButton: PaymentSheetPrimaryButtonAppearance(
            colors: PaymentSheetPrimaryButtonTheme(
              dark: PaymentSheetPrimaryButtonThemeColors(
                background: Colors.red,
                text: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.localizedMessage != null &&
          e.error.localizedMessage!.contains('canceled')) {
        return false;
      } else {
        throw Exception('Payment failed: ${e.error.localizedMessage}');
      }
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }
}
