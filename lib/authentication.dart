import 'package:app/models/account.dart';
import 'package:flutter/material.dart';
import 'package:app/client.dart';

import 'package:app/storage.dart'
  if (dart.library.html) 'package:app/web_storage.dart';

class Authentication {
  static BuildContext appContext;

  static Account currentAccount = Account();
  static String token;

  static void setEmail(email) {
    if (currentAccount.email != email)
      currentAccount = Account(email: email);
    saveToDisk();
  }

  static Future<Account> getAccount() async {
    return await Client.getAccount().then((response) {
      if (response['success'])
        setCurrentAccount(Account.fromMap(response['body']));
      else logout();

      return currentAccount;
    });
  }

  static Future<Map<dynamic, dynamic>> updateAccount([data]) async {
    var accountData = currentAccount.toMap();
    setCurrentAccount(Account.fromMap({
      ...accountData,
      ...data
    }));
    return await Client.updateAccount(currentAccount.toMap());
  }

  static void setToken(identifier) {
    token = identifier;
    saveToDisk();
  }

  static void setCurrentAccount(newAccount) {
    currentAccount = newAccount;
    saveToDisk();
  }

  static bool isAuthenticated() {
    return token != null;
  }

  static Future<bool> checkForAuth() async {
    return await readFromDisk('token').then((accessToken) {
      readFromDisk('currentAccount').then((json) {
        currentAccount = Account.fromJson(json);
      });
      token = accessToken;
      return token != null;
    });
  }

  static Future<String> readFromDisk(key) async {
    return Storage.read(key);
  }

  static void saveToDisk() async {
    await Storage.write('token', token);
    await Storage.write('currentAccount', currentAccount.toJson());
  }

  static void logout() {
    currentAccount = Account();
    setToken(null);
    Navigator.pushNamedAndRemoveUntil(appContext, '/login', (Route<dynamic> route) => false);
  }
}
