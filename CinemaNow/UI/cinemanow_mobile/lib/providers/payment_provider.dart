import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:cinemanow_mobile/providers/base_provider.dart';

class PaymentProvider extends BaseProvider {
  PaymentProvider() : super("api/Payment");

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
      ),
    );
  }

  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      throw Exception('Payment failed: $e');
    }
  }
}
