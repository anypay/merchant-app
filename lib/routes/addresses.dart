import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/app_controller.dart';
import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import '../coins.dart';

class Addresses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddressesPage(title: 'Addresses');
  }
}

class AddressesPage extends StatefulWidget {
  AddressesPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _AddressesPageState createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  @override
  void initState() {
    super.initState();
    if (Coins.all.length == 0)
      Authentication.fetchCoins().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ..._newAddressLinks(),
                CircleBackButton(
                  margin: EdgeInsets.only(top: 20.0),
                  backPath: 'settings',
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _newAddressLinks() {
    if (Coins.all.length == 0)
      return [SpinKitCircle(color: AppController.blue)];
    else {
      List<CoinCode> coinList = Coins.supported.keys.toList();

      coinList.sort((a, b) => a.code.compareTo(b.code));

      return coinList.map((coinCode) =>
          Container(
              height: 100,
              width: 400,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.pushNamed(context, 'new-address/${coinCode.code}/${coinCode.chain}');
                  },
                  child: Row(
                      children: [
                        Container(
                          width: 75,
                          margin: EdgeInsets.only(
                            top: 10.0,
                            left: 50.0,
                            right: 40.0,
                            bottom: 10.0,
                          ),
                          child: Image.network(
                              Coins.supported[coinCode]['icon']
                          ),
                        ),
                        Expanded(
                          child: Text(
                              Coins.supported[coinCode]['name'],
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Theme.of(context).primaryColorLight
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.fade
                          ),
                        ),
                      ]
                  )
              )
          )
      ).toList();
    }
  }
}



