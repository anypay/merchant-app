import 'package:flutter/material.dart';

class NewInvoice extends StatelessWidget {
  static const String route = '/';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // if (true)
    return MaterialApp(
      title: 'Anypay Cash Register',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NewInvoicePage(title: 'Anypay Cash Register'),
    );
  }


class NewInvoicePage extends StatefulWidget {
  NewInvoicePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewInvoicePageState createState() => _NewInvoicePageState();
}

class _NewInvoicePageState extends State<NewInvoicePage> {
  String _visiblePrice = 0.toStringAsFixed(2);
  double _price = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '\$$_visiblePrice',
              style: Theme.of(context).textTheme.headline3,
            ),
            Row(
              children: <Widget>[
                ..._generateNumberButtons(),
                GestureDetector(
                  onTap: _backspace,
                  child: Text("⌫",
                    style: Theme.of(context).textTheme.headline4,
                  )
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.settings),
        tooltip: 'Settings',
      ),
    );
  }



  void _backspace() {
    setState(() {
      _price = (_price * 10).truncateToDouble()/100;
      _visiblePrice = _price.toStringAsFixed(2);
    });
  }

  void _updatePrice(i) {
    setState(() {
      _price = (_price * 1000 + i).truncateToDouble()/100;
      _visiblePrice = _price.toStringAsFixed(2);
    });
  }

  List<Widget> _generateNumberButtons() {
    return List<Widget>.generate(10, (i)  {
        int num = (i + 1) % 10;
      return GestureDetector(
        onTap: () { _updatePrice(num); },
        child: Container(
          child: Text(
            num.toString(),
            style: Theme.of(context).textTheme.headline4,
          ),
          margin: EdgeInsets.all(8),
        )
      );
    });
  }

}

