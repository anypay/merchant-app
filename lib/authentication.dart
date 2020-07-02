import 'package:app/push_notifications.dart';
import 'package:app/models/account.dart';
import 'package:flutter/material.dart';
import 'package:app/app_builder.dart';
import 'package:app/client.dart';

import 'package:app/native_storage.dart'
  if (dart.library.html) 'package:app/web_storage.dart';

class Authentication {
  static BuildContext appContext;

  static Account currentAccount = Account();
  static String token;

  static void setEmail(email) {
    if (currentAccount.email != email)
      setCurrentAccount(Account(email: email));
  }

  static Future<Account> getAccount() async {
    return await Client.getAccount().then((response) {
      if (response['success'])
        setCurrentAccount(Account.fromMap(response['body']));

      return currentAccount;
    });
  }

  static Future<Map<dynamic, dynamic>> updateAccount([data]) async {
    var accountData = currentAccount.toMap();
    var newAccount = Account.fromMap({
      ...accountData,
      ...data
    });
    return await Client.updateAccount(newAccount.toMap()).then((response) {
      if (response['success'])
        setCurrentAccount(newAccount);
      return response;
    });
  }

  static Future<void> setToken(uid) {
    token = uid;
    return saveTokenToDisk();
  }

  static void setCurrentAccount(newAccount) {
    currentAccount = newAccount;
    ensureNotificationPermission();
    saveAccountToDisk();
    fetchCoins();
  }

  static void ensureNotificationPermission() {
    if (isAuthenticated())
      PushNotificationsManager().init();
  }

  static Future<void> fetchCoins() async {
    if (isAuthenticated())
      currentAccount.fetchingCoins = true;
      Client.fetchCoins().then((response) {
        currentAccount.fetchingCoins = false;
        if (response['success']) {
          var coins = response['body']['coins'];
          coins.removeWhere((coin) => !coin['enabled']);
          currentAccount.coins = coins;
        }
      });
  }

  static bool isAuthenticated() {
    return token != null;
  }

  static Future<bool> checkForAuth() async {
    return await readFromDisk('token').then((accessToken) {
      token = accessToken;

      if (accessToken != null)
        return readFromDisk('currentAccount').then((json) {
          if (json != null)
            setCurrentAccount(Account.fromJson(json));

          return true;
        });
      else return false;
    });
  }

  static Future<String> readFromDisk(key) async {
    return Storage.read(key);
  }

  static Future<void> saveTokenToDisk() async {
    if (token == null)
      return await Storage.delete('token');
    else
      return await Storage.write('token', token);
  }

  static void saveAccountToDisk() async {
    await Storage.write('currentAccount', currentAccount.toJson());
  }

  static void logout() {
    setToken(null);
    setCurrentAccount(Account());
    Navigator.pushNamedAndRemoveUntil(appContext, '/login', (Route<dynamic> route) => false);
  }
}
