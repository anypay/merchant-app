import 'package:flutter/material.dart';
import '../coins.dart';

class QuickStart extends StatelessWidget {
  static const String route = '/quick-start';
  @override
  Widget build(BuildContext context) {
    return QuickStartPage(title: 'Quick Start');
  }
}

class QuickStartPage extends StatefulWidget {
  QuickStartPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _QuickStartPageState createState() => _QuickStartPageState();
}

class _QuickStartPageState extends State<QuickStartPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _newAddressLinks(),
        ),
      ),
    );
  }

  List<GestureDetector> _newAddressLinks() {
    return Coins.all.keys.map((code) =>
      GestureDetector(
        onTap: () => {
          Navigator.pushNamed(context, '/new-address/$code')
        },
        child: Text(
          Coins.all[code]['name'],
          style: Theme.of(context).textTheme.headline2,
        )
      )
    ).toList();
  }
}


