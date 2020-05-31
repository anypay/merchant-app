import 'package:flutter/material.dart';
import 'package:app/preloader.dart';

class NewInvoice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Preloader.downloadImages(context);

    return NewInvoicePage(title: 'Anypay Cash Register');
  }
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
      body: Center(
        child: Container(
          width: 300,
          margin: EdgeInsets.only(top: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '\$$_visiblePrice',
                style: Theme.of(context).textTheme.headline3,
              ),
              Wrap(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  ..._generateNumberButtons(),
                  Container(
                    width: 100,
                    margin: EdgeInsets.only(top: 8, bottom: 8),
                    child: GestureDetector(
                      onTap: _backspace,
                      child: Text("⌫",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        )
                      )
                    )
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/navigation'),
        child: Icon(Icons.settings),
        tooltip: 'navigation',
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
    return List<Widget>.generate(11, (i)  {
      int num = (i + 1) % 11;
      return GestureDetector(
        onTap: () { _updatePrice(num); },
        child: Container(
          width: 100,
          child: Text(
            num == 10 ? '' : num.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            )
          ),
          margin: EdgeInsets.only(top: 8, bottom: 8),
        )
      );
    });
  }

}

