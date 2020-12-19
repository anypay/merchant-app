import 'package:basic_utils/basic_utils.dart';
import 'models/invoice.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Client {
  static final protocol = 'https';
  static final domain = 'api.anypayinc.com';
  static final host = "$protocol://$domain";

  static String humanize(str) {
    if (str != null && str.length > 0)
      return StringUtils.capitalize(str);
  }

  static Future<Map<dynamic, dynamic>> getAccount(id) async {
    var response = await makeRequest('get',
      path: '/accounts/$id',
    );

    return response;
  }

  static Future<Map<dynamic, dynamic>> getInvoice(id) async {
    var response = await makeRequest('get',
      path: '/invoices/$id',
    );

    if (response['success'])
      response['invoice'] = Invoice.fromMap(response['body']);

    return response;
  }

  static Future<Map<dynamic, dynamic>> makeRequest(method, {path, uri, headers, body, genericErrorCodes}) async {
    try {
      http.Request request = http.Request(method, uri ?? Uri.parse('$host$path'));
      if (genericErrorCodes == null) genericErrorCodes = [500];

      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.body = jsonEncode(body ?? {});
      (headers ?? {}).forEach((key, value) {
        request.headers[key] = value;
      });

      http.StreamedResponse streamedResponse = await http.Client().send(request);
      http.Response response = await http.Response.fromStream(streamedResponse);

      var responseBody = (json.decode(response.body) as Map);
      var message = responseBody['message'];

      var code = response.statusCode;
      // For debugging: 
      // print("PATH: $path, BODY: ${jsonEncode(body ?? {})}, CODE: $code");
      if (response.statusCode == 401) {
        return {
          'message': 'Unauthorized',
          'success': false,
          'body': { },
        };
      } else if (genericErrorCodes.contains(response.statusCode)) {
        return {
          'success': false,
          'message': "Something went wrong, please try again later",
          'body': { },
        };
      } else return {
        'success': response.statusCode == 200,
        'message': humanize(message ?? ""),
        'body': responseBody,
      };
    } on SocketException catch (_) {
      return {
        'message': 'Not connected to the internet',
        'success': false,
        'body': { },
      };
    }
  }
}
