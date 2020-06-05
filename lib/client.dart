import 'package:basic_utils/basic_utils.dart';
import 'package:app/authentication.dart';
import 'package:app/models/account.dart';
import 'package:app/models/invoice.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Client {
  static final host = 'https://api.anypayinc.com';

  static String humanize(str) {
    if (str != null && str.length > 0)
      return StringUtils.capitalize(str);
  }
     
  static String buildAuthHeader() {
    String token = Authentication.token;
    return 'Basic ' + base64.encode(utf8.encode('$token:'));
  }

  static Future<Map<dynamic, dynamic>> fetchCoins() async {
    http.Response response = await http.get(
      '$host/coins',
      headers: <String, String>{
        'authorization': buildAuthHeader(),
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 401)
      Authentication.logout();
    else
      return {
        'success': response.statusCode == 200,
        'body': (json.decode(response.body) as Map),
      };
  }

  static Future<Map<dynamic, dynamic>> getAccount() async {
    http.Response response = await http.get(
      '$host/account',
      headers: <String, String>{
        'authorization': buildAuthHeader(),
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 401)
      Authentication.logout();
    else
      return {
        'success': response.statusCode == 200,
        'body': (json.decode(response.body) as Map),
      };
  }

  static Future<Map<dynamic, dynamic>> createAccount(email, password) async {
    http.Response response = await http.post(
      '$host/accounts',
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final body = (json.decode(response.body) as Map);

    return {
      'success': response.statusCode == 200,
      'message': humanize(body['message']),
    };
  }

  static Future<Map<dynamic, dynamic>> updateAccount(data) async {
    http.Response response = await http.put(
      '$host/account',
      body: jsonEncode(data),
      headers: <String, String>{
        'authorization': buildAuthHeader(),
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final body = (json.decode(response.body) as Map);

    return {
      'success': response.statusCode == 200,
      'message': humanize(body['message']),
    };
  }

  static Future<Map<dynamic, dynamic>> resetPassword(email) async {
    http.Response response = await http.post(
      '$host/password-resets',
      body: jsonEncode(<String, String>{
        'email': email.trim(),
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final body = (json.decode(response.body) as Map);

    return {
      'success': response.statusCode == 200,
      'message': humanize(body['message']),
    };
  }

  static Future<Map<dynamic, dynamic>> authenticate(email, password) async {
    email = email.trim().toLowerCase();
    String basicAuth = 'Basic ' + base64.encode(utf8.encode('$email:$password'));

    http.Response response = await http.post(
      '$host/access_tokens',
      body: jsonEncode(<String, String>{}),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': basicAuth,
      },
    );

    final body = (json.decode(response.body) as Map);

    if (response.statusCode == 200) {
      Authentication.setToken(body['uid']);
      Authentication.setEmail(email);
    }

    return {
      'success': response.statusCode == 200,
      'message': humanize(body['message']),
    };
  }

  static Future<Map<dynamic, dynamic>> setAddress(code, address) async {
    http.Response response = await http.put(
      '$host/addresses/$code',
      body: jsonEncode(<String, String>{
        'address': address,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': buildAuthHeader(),
      },
    );

    final body = (json.decode(response.body) as Map);

    return {
      'success': response.statusCode == 200,
      'message': humanize(body['message']),
    };
  }

  static Future<Map<dynamic, dynamic>> getInvoice(id) async {
    http.Response response = await http.get(
      '$host/invoices/$id',
      headers: <String, String>{
        'authorization': buildAuthHeader(),
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final body = (json.decode(response.body) as Map<String, dynamic>);
    final success = response.statusCode == 200;

    if (response.statusCode == 401)
      Authentication.logout();
    else return {
        'success': success,
        'message': humanize(body['message']),
        'invoice': success ? Invoice.fromMap(body) : null,
      };
  }

  static Future<Map<dynamic, dynamic>> createInvoice(amount, currency) async {
    http.Response response = await http.post(
      '$host/invoices',
      body: jsonEncode({
        'amount': amount,
        'currency': currency,
      }),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': buildAuthHeader(),
      },
    );

    final body = (json.decode(response.body) as Map);

    return {
      'success': response.statusCode == 200,
      'message': humanize(body['message']),
      'invoiceId': body['uid'],
    };
  }
}
