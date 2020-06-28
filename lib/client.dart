import 'package:basic_utils/basic_utils.dart';
import 'package:app/authentication.dart';
import 'package:app/models/account.dart';
import 'package:app/models/invoice.dart';
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

  static String buildAuthHeader() {
    String token = Authentication.token;
    return 'Basic ' + base64.encode(utf8.encode('$token:'));
  }

  static Future<Map<dynamic, dynamic>> setInvoiceNotes(invoiceId, notes) async {
    return makeRequest('post',
      path: '/invoices/$invoiceId/notes',
      unauthorized: (() => Authentication.logout()),
      body: { 'note': notes },
      requireAuth: true,
    );
  }

  static Future<Map<dynamic, dynamic>> fetchCoins() async {
    return makeRequest('get',
      unauthorized: (() => Authentication.logout()),
      requireAuth: true,
      path: '/coins',
    );
  }

  static Future<Map<dynamic, dynamic>> getAccount() async {
    return makeRequest('get',
      unauthorized: (() => Authentication.logout()),
      requireAuth: true,
      path: '/account',
    );
  }

  static Future<Map<dynamic, dynamic>> createAccount(email, password) async {
    return makeRequest('post',
      path: '/accounts',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
  }

  static Future<Map<dynamic, dynamic>> updateAccount(data) async {
    return makeRequest('put',
      requireAuth: true,
      path: '/account',
      body: data,
    );
  }

  static Future<Map<dynamic, dynamic>> resetPassword(email) async {
    return makeRequest('post',
      path: '/password-resets',
      body: {
        'email': email.trim(),
      },
    );
  }

  static Future<Map<dynamic, dynamic>> authenticate(email, password) async {
    email = email.trim().toLowerCase();
    String basicAuth = 'Basic ' + base64.encode(utf8.encode('$email:$password'));

    var response = await makeRequest('post',
      path: '/access_tokens',
      basicAuth: basicAuth,
    );

    if (response['success']) {
      Authentication.setToken(response['body']['uid']);
      Authentication.setEmail(email);
    }

    return response;
  }

  static Future<Map<dynamic, dynamic>> setAddress(code, address) async {
    return makeRequest('put',
      body: { 'address': address },
      path: '/addresses/$code',
      requireAuth: true,
    );
  }

  static Future<Map<dynamic, dynamic>> getInvoices({page}) async {
    var perPage = 100;
    var offset = perPage * (page - 1 ?? 0);

    var response = await makeRequest('get',
      unauthorized: (() => Authentication.logout()),
      uri: Uri.https(domain, '/invoices', {
        'limit': perPage.toString(),
        'offset': offset.toString(),
      }),
      requireAuth: true,
    );

    if (response['success']) {
      var data = (response['body']['invoices'] as List<dynamic>);
      var invoices = data.map((invoice) => Invoice.fromMap(invoice));
      response['invoices'] = invoices.toList();
    }

    return response;
  }


  static Future<Map<dynamic, dynamic>> getInvoice(id) async {
    var response = await makeRequest('get',
      unauthorized: (() => Authentication.logout()),
      path: '/invoices/$id',
      requireAuth: true,
    );

    if (response['success'])
      response['invoice'] = Invoice.fromMap(response['body']);

    return response;
  }

  static Future<Map<dynamic, dynamic>> createInvoice(amount, currency) async {
    var response = await makeRequest('post',
      requireAuth: true,
      path: '/invoices',
      body: {
        'amount': amount,
        'currency': currency,
      },
    );

    if (response['success'])
      response['invoiceId'] = response['body']['uid'];

    return response;
  }

  static Future<Map<dynamic, dynamic>> makeRequest(method, {path, uri, headers, body, requireAuth, basicAuth, unauthorized}) async {
    try {
      http.Request request = http.Request(method, uri ?? Uri.parse('$host$path'));
      if (requireAuth ?? false) request.headers['authorization'] = buildAuthHeader();
      if (basicAuth != null) request.headers['authorization'] = basicAuth;

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
      if (response.statusCode == 401 && unauthorized != null)
        return unauthorized();
      else return {
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
