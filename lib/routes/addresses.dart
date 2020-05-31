import 'package:flutter/material.dart';
import '../coins.dart';

class Addresses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddressesPage(title: 'Addresses');
  }
}

class AddressesPage extends StatefulWidget {
  AddressesPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AddressesPageState createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ..._newAddressLinks(),
            Container(
              margin: EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                onPressed: () {
                  if (Navigator.canPop(context))
                    Navigator.pop(context, true);
                  else
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (Route<dynamic> route) => false);
                },
                child: Text('BACK'),
              ),
            ),
          ]
        ),
      ),
    );
  }

  List<Widget> _newAddressLinks() {
    return Coins.all.keys.map((code) =>
      Container(
        height: 100,
        child: GestureDetector(
          onTap: () => {
            Navigator.pushNamed(context, '/new-address/$code')
          },
          child: Row(
            children: [
              Container(
                width: 75,
                margin: EdgeInsets.only(
                  top: 10.0,
                  left: 50.0,
                  right: 50.0,
                  bottom: 10.0,
                ),
                child: Image.network(
                  Coins.all[code]['icon']
                ),
              ),
              Text(
                Coins.all[code]['name'],
                style: TextStyle(
                  fontSize: 22,
                ),
              )
            ]
          )
        )
      )
    ).toList();
  }
}



