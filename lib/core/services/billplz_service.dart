import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/billplz_config.dart';

/// Represents a Billplz bill returned by the API.
class BillplzBill {
  final String id;
  final String collectionId;
  final String url;
  final bool paid;
  final String state; // 'due', 'paid', 'deleted', 'overdue'
  final String? paidAt;

  const BillplzBill({
    required this.id,
    required this.collectionId,
    required this.url,
    required this.paid,
    required this.state,
    this.paidAt,
  });

  factory BillplzBill.fromJson(Map<String, dynamic> json) {
    return BillplzBill(
      id: json['id'] as String,
      collectionId: json['collection_id'] as String,
      url: json['url'] as String,
      paid: json['paid'] as bool? ?? false,
      state: json['state'] as String? ?? 'due',
      paidAt: json['paid_at'] as String?,
    );
  }
}

/// Thin wrapper around the Billplz v3 REST API.
///
/// NOTE: For production, proxy these calls through a Supabase Edge Function
/// so the API key is not shipped inside the app bundle.
class BillplzService {
  BillplzService._();
  static final BillplzService instance = BillplzService._();

  /// Returns Basic-auth header value for [BillplzConfig.apiKey].
  String get _authHeader {
    final credentials = base64Encode(
      utf8.encode('${BillplzConfig.apiKey}:'),
    );
    return 'Basic $credentials';
  }

  Map<String, String> get _headers => {
        'Authorization': _authHeader,
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  /// Creates a Billplz bill and returns it, or throws on error.
  ///
  /// [email] – payer's email (required by Billplz).
  /// [name]  – payer's display name.
  /// [amountCents] – amount in sen (RM 19.90 = 1990).
  /// [description] – bill description shown on the payment page.
  Future<BillplzBill> createBill({
    required String email,
    required String name,
    required int amountCents,
    required String description,
  }) async {
    final uri = Uri.parse('${BillplzConfig.baseUrl}/bills');

    final body = {
      'collection_id': BillplzConfig.collectionId,
      'email': email,
      'name': name,
      'amount': amountCents.toString(),
      'callback_url': BillplzConfig.callbackUrl,
      'redirect_url': BillplzConfig.redirectUrl,
      'description': description,
    };

    final response = await http.post(uri, headers: _headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return BillplzBill.fromJson(json);
    } else {
      throw Exception(
        'Billplz createBill failed [${response.statusCode}]: ${response.body}',
      );
    }
  }

  /// Fetches the current status of an existing bill by [billId].
  Future<BillplzBill> getBill(String billId) async {
    final uri = Uri.parse('${BillplzConfig.baseUrl}/bills/$billId');

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return BillplzBill.fromJson(json);
    } else {
      throw Exception(
        'Billplz getBill failed [${response.statusCode}]: ${response.body}',
      );
    }
  }
}
