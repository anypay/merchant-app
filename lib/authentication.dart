import 'package:app/push_notifications.dart';
import 'package:app/models/address.dart';
import 'package:app/models/account.dart';
import 'package:app/app_controller.dart';
import 'package:app/preloader.dart';
import 'package:app/client.dart';
import 'package:app/coins.dart';
import 'dart:async';

import 'package:app/native_storage.dart';

class Authentication {
  static Account currentAccount = Account();
  static String? token;

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
    ensureNotifications();
    saveAccountToDisk();
    fetchCoins();
  }

  static void ensureNotifications() {
    if (isAuthenticated()) {
      Timer(Duration(milliseconds: 1000), () => PushNotificationsManager().init());
    }
  }

  static Future<void> fetchCoins() async {
    if (isAuthenticated()) {
      currentAccount.fetchingCoins = true;
      await Client.fetchCoins().then((response) {
        currentAccount.fetchingCoins = false;
        if (response['success']) {
          var coins = response['body']['coins'] ?? [];
          Coins.all = {};
          coins.forEach((coin) {
            var coinCode = CoinCode(coin['code'], coin['chain']);

            Coins.all[coinCode] = {
              'name': coin['name'],
              'decimals': coin['decimals'],
              'icon': coin['icon']
            };
            if (coin['supported'] == true)
              Coins.supported[coinCode] = {
                'name': coin['name'],
                'icon': coin['icon'],
                'decimals': coin['decimals'],
              };
          });
          coins.removeWhere((coin) => !coin['enabled']);
          currentAccount.coins = coins;
          Preloader.downloadImages();
        }
      });

      await Client.fetchAccountAddresses().then((response) {
        response['body']['addresses'].forEach((address) {
          currentAccount.addresses[CoinCode(address['currency'], address['chain'])] = Address.fromMap(address);
        });
      });
    }
  }

  static bool isAuthenticated() {
    return token != null;
  }

  static Future<bool> checkForAuth() async {
    return await readFromDisk('token').then((accessToken) {
      if (accessToken == 'null') accessToken = null;

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

  static Future<String?> readFromDisk(key) async {
    return Storage.read(key);
  }

  static Future<void> saveTokenToDisk() async {
    if (token == null)
      return await Storage.delete('token');
    else
      return await Storage.write('token', token!);
  }

  static void saveAccountToDisk() async {
    await Storage.write('currentAccount', currentAccount.toJson());
  }

  static void logout() {
    setToken(null);
    setCurrentAccount(Account());
    AppController.closeUntilPath('/login');
  }
}
