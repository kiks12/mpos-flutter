
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mpos/models/sale.dart';
import 'package:mpos/services/shared_preferences_service.dart';
import 'package:http/http.dart' as http;

class SalesIngestionService {

  static Future<bool> postSale(Sale sale) async {
    final deviceId = await SharedPreferencesService.get('device_id');
    final deviceToken = await SharedPreferencesService.get('device_token');
    final locationId = await SharedPreferencesService.get('location_id');
    final userId = await SharedPreferencesService.get('user_id');
    final url = Uri.parse(dotenv.get('SALES_INGESTION_EDGE_URL'));
    final token = dotenv.get('SUPABASE_ANON_KEY');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'transaction_id': sale.transactionID,
      'user_id': userId,
      'location_id': locationId,
      'device_id': deviceId,
      'employee_id': sale.employeeId,
      'employee_name': sale.employeeName,
      'total_amount': sale.totalAmount,
      'device_token': deviceToken,
      'location_name': sale.locationName,
      'sub_total': sale.subTotal,
      'discount': sale.discount,
      'payment': sale.payment,
      'change': sale.change,
      'payment_method': sale.paymentMethod,
      'reference_number': sale.referenceNumber,
      'products': jsonDecode(sale.productsJson),
      'packages': jsonEncode(sale.packagesJson),
      'items_count': sale.products.length + sale.packages.length,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print("SALES INGESTION RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error :$e');
      return false;
    }
  }
}