import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:app/models/merchant.dart';
import 'package:app/authentication.dart';
import 'package:app/models/invoice.dart';
import 'package:app/app_controller.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/back_button.dart';
import 'package:share/share.dart';
import 'package:app/events.dart';
import 'package:app/client.dart';
import 'package:app/coins.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher_string.dart';


class ShowInvoice extends StatelessWidget {
  ShowInvoice(this.id);

  final String id;

  @override
  Widget build(BuildContext context) {
    return InvoicePage(id: id);
  }
}

class InvoicePage extends StatefulWidget {
  InvoicePage({Key key, this.id}) : super(key: key);

  final String id;

  @override
  _InvoicePageState createState() => _InvoicePageState(id);
}

class _InvoicePageState extends State<InvoicePage> {
  _InvoicePageState(this.id);

  TextEditingController notes = TextEditingController();
  Map<String, dynamic> chosenPaymentOption;
  bool _showLinkToWalletHelp = false;
  bool choosingCurrency = false;
  String _successMessage = '';
  bool usePayProtocol = true;
  bool _invoiceReady = false;
  bool _submitting = false;
  StreamSubscription event;
  Timer havingTroubleTimer;
  bool useUrlStyle = true;
  bool _disposed = false;
  Timer periodicRequest;
  String _errorMessage;
  String notesError;
  String currency;
  Color qrColor;
  String uri;
  String id;

  Invoice invoice;
  RectGetter sharePlacement;

  Map<String, dynamic> get bsvPaymentOption => invoice.bsvPaymentOption;
  List<dynamic> get embedOutputs {
    if (bsvPaymentOption == null) return [];
    return (bsvPaymentOption['outputs'] ?? []).map((output) {
      var _output = {};
      _output['amount'] = output['amount']/100000000;
      _output['to'] = output['address'];
      _output['currency'] = 'BSV';
      return _output;
    }).toList();
  }

  Map arguments;
  Merchant merchant;

  @override
  Widget build(BuildContext context) {
    arguments ??= (ModalRoute.of(context).settings.arguments as Map);
    if (arguments != null) merchant ??= arguments['merchant'];

    return GestureDetector(
      onTap: _closeKeyboard,
      child: Scaffold(
        floatingActionButton: Visibility(
          visible: _showInvoice(),
          child: GestureDetector(
            onTap: _openHelpUrl,
            child: Image(
              image: AssetImage(AppController.havingIssuesImagePath()),
              width: AppController.scale(40),
            )
          )
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _PageContent(),
                _BackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    event.cancel();
    notes.dispose();
    super.dispose();
    _disposed = true;
    periodicRequest.cancel();
    havingTroubleTimer.cancel();
  }

  void _copyUri() {
    Clipboard.setData(ClipboardData(text: uri));
    setState(() => _successMessage = "Copied!" );
    Timer(Duration(seconds: 2), () {
      setState(() => _successMessage = "" );
    });
  }

  void _openHelpUrl() async {
    await launchUrlString("https://anypayx.com/faq");
  }

  void _openUri() async {
    await launchUrlString(uri);
  }

  bool hasNotes = false;

  void _done() {
    if (_submitting) return;
    _closeKeyboard();
    setState(() {
      _submitting = true;
      notesError = "";
    });
    periodicRequest.cancel();

    if (hasNotes)
      Client.setInvoiceNotes(invoice.uid, notes.text).then((response) {
        _submitting = false;
        if (response['success']) {
          if (merchant == null && Authentication.isAuthenticated())
            _backToNewInvoice();
          else setState(() {});
        } else setState(() => notesError = 'something went wrong!');
      });
    else _backToNewInvoice();
  }

  void _backToNewInvoice() {
    if (Authentication.isAuthenticated())
      AppController.closeUntilPath(backPath);
  }

  String get backPath {
    if (invoice != null && !Authentication.isAuthenticated())
      return '/pay/${invoice.accountId}';
    else return '/new-invoice';
  }


  void _toggleUrlStyle() {
    useUrlStyle = !useUrlStyle;
    _rebuild();
  }

  void _chooseCurrency() {
    if (invoice.paymentOptions.length > 1)
      choosingCurrency = true;
    _rebuild();
  }

  void _shareUri() async {
    var shareUri = "https://anypayx.com/i/${invoice?.uid}";

    await Share.share(shareUri,
      sharePositionOrigin: sharePlacement.getRect()
    );
  }

  String getFormat() {
    if (usePayProtocol)
      return 'pay';
    else if (useUrlStyle)
      return 'url';
  }

  void _rebuild() {
    setState(() {
      currency = currency ?? invoice?.currency;
      uri = invoice?.uriFor(currency, format: getFormat());
    });
    if (invoice != null && _invoiceReady == false) {
      Timer(Duration(milliseconds: 10), () {
        _invoiceReady = true;
        _rebuild();
      });
    }
  }

  void _fetchInvoice() {
    if (invoice == null || (invoice.isUnpaid() && !invoice.isExpired()))
      Client.getInvoice(id).then((response) {
        _errorMessage = null;
        if (response['success']) {
          invoice = response['invoice'];
          if (invoice.paymentOptions.length == 1) {
            chosenPaymentOption = invoice.paymentOptions.first;
            usePayProtocol = false;
          }
        } else _errorMessage = response['message'];

        // Checking if disposed to prevent memory leaks
        if (!_disposed) _rebuild();
      });
  }

  @override
  void initState() {
    super.initState();
    _fetchInvoice();
    qrColor = AppController.randomColor;
    periodicRequest = Timer.periodic(Duration(seconds: 2), (timer) => _fetchInvoice());
    havingTroubleTimer = Timer(Duration(seconds: 50), () {
      setState(() => _showLinkToWalletHelp = true );
    });
    event = Events.on('invoice.paid', (payload) {
      invoice = Invoice.fromMap(payload);
      _rebuild();
    });
  }

  Widget _ChooseCurrencyMenu() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 300,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: _PaymentTitle('anypay'),
            onTap: () {
              choosingCurrency = false;
              usePayProtocol = true;
              _rebuild();
            },
          )
        ),
        ...(invoice.paymentOptions.map((option) {
          return Container(
            width: 300,
            margin: EdgeInsets.only(top: 10),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: _PaymentTitle(option['currency'], paymentOption: option),
              onTap: () {
                currency = option['currency'];
                chosenPaymentOption = option;
                choosingCurrency = false;
                usePayProtocol = false;
                useUrlStyle = true;
                _rebuild();
              },
            )
          );
        })),
      ]
    );
  }

  Widget _UnderpaidScreen() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: AppController.red,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 120,
          ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20),
            child: Text(invoice.amountWithDenomination(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.lineThrough,
                color: Theme.of(context).primaryColorLight,
                fontSize: 28,
              ),
            ),
          ),
          Text(invoice.paidAmountWithDenomination(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorLight,
              fontSize: 28,
            ),
          ),
          _BackButton(),
        ]
      )
    );
  }

  Widget _WebShareOptions() {
    return Container(
      width: 235,
      margin: EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _copyUri,
            child: Row(
              children: <Widget>[
                Text('Copy', style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                )),
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Image(
                    image: AppController.enableDarkMode ?
                      AssetImage('assets/images/copy_icon-white.png') :
                      AssetImage('assets/images/copy_icon.png'),
                    width: 20,
                  )
                )
              ]
            )
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _openUri,
            child: Row(
              children: <Widget>[
                Text('Open Wallet', style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                )),
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Image(
                    image: AppController.enableDarkMode ?
                      AssetImage('assets/images/wallet_icon-white.png') :
                      AssetImage('assets/images/wallet_icon.png'),
                    width: 20,
                  )
                )
              ]
            )
          ),
        ]
      ),
    );
  }

  Widget _PaidScreen() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Image(
              width: AppController.scale(140),
              image: AssetImage('assets/images/anypay-logo.png')
            ),
          ),
          ConfettiWidget(
            confettiController: ConfettiController(
              duration: Duration(seconds: 1),
            )..play(),
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 60,
            minBlastForce: 30,
            numberOfParticles: 20,
            shouldLoop: false,
            colors: AppController.colors,
          ),
          Container(
            child: Text('PAID!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF34b83a),
                fontSize: AppController.scale(48, minValue: 44),
              ),
            ),
          ),
          Container(
            child: Text(Authentication.currentAccount.businessName ?? "",
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: AppController.scale(35), bottom: 5),
            child: Text(invoice.amountWithDenomination(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
                fontSize: 28,
              ),
            ),
          ),
          Visibility(
            visible: (invoice.notes ?? []).length > 0,
            child: Column(
              children: [
                Text("Order Notes:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).primaryColorDark,
                    fontSize: 20,
                  ),
                ),
                Container(
                  width: 300,
                  margin: EdgeInsets.only(top: 5),
                  child: Text(invoice.noteText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColorDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 300,
            child: !Authentication.isAuthenticated() ? null : TextFormField(
              controller: notes,
              onChanged: (value) {
                if (value.length > 0 != hasNotes)
                  setState(() => hasNotes = value.length > 0);
              },
              validator: (value) {
                if (notesError.length > 0)
                  return notesError;
              },
              decoration: InputDecoration(
                labelText: 'Add note...'
              ),
            ),
          ),
          Visibility(
            visible: ((merchant == null && Authentication.isAuthenticated()) || hasNotes),
            maintainAnimation: true,
            maintainState: true,
            maintainSize: true,
            child: Container(
              margin: EdgeInsets.only(top: AppController.scale(30), bottom: 20),
              child: _submitting ?
                SpinKitCircle(
                    size: AppController.scale(50, minValue: 40),
                    color: AppController.randomColor,
                ) : GestureDetector(
                  onTap: _done,
                  child: Image(
                    image: AssetImage('assets/images/next_arrow.png'),
                    width: 50,
                  )
                ),
            )
          )
        ]
      )
    );
  }

  Widget _ExpiredInvoice() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 35),
          child: Text("Invoice Expired",
            style: TextStyle(
              fontSize: 31,
              color: Theme.of(context).primaryColorLight,
            )
          )
        ),
        GestureDetector(
          onTap: _done,
          child: Image(
            image: AssetImage('assets/images/next_arrow.png'),
            width: 60,
          )
        ),
      ],
    );
  }

  Widget _PaymentTitle(currency, {paymentOption}) {
    paymentOption = paymentOption ?? chosenPaymentOption;
    var coinDetailsSpecified = paymentOption != null;
    var coinIsSupported = Coins.supported[currency] != null;

    paymentOption = paymentOption ?? {};
    if (currency == 'anypay' || coinIsSupported || coinDetailsSpecified)
      return Container(
        child: Row(
          children: currency == 'anypay' ? [
            Container(
              width: 60,
              child: Image(
                image: AssetImage('assets/images/anypay-logo.png')
              ),
            ),
            Text('Anypay',
              style: TextStyle(fontSize: 35),
            ),
          ] : [
            Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 15, bottom: 15),
              child: Image.network(paymentOption['currency_logo_url'] ?? Coins.supported[currency]['icon']),
            ),
            Text(paymentOption['currency_name'] ?? Coins.supported[currency]['name'],
              style: TextStyle(fontSize: 40),
            ),
          ]
        )
      );
    else return Container();
  }

  bool _showInvoice() {
    return invoice != null &&
      !invoice.isUnderpaid() &&
      !invoice.isExpired() &&
      !invoice.isPaid() &&
      !choosingCurrency;
  }

  Widget _PageContent() {
    if (_showInvoice())
      return _InvoiceComponent();
    else if (invoice == null)
      if (_errorMessage != null)
        return Text(_errorMessage, style: TextStyle(color: AppController.red));
      else return Container(
          child: SpinKitCircle(color: qrColor),
          height: AppController.scale(360),
        );
    else if (invoice.isUnderpaid())
      return _UnderpaidScreen();
    else if (invoice.isPaid())
      return _PaidScreen();
    else if (choosingCurrency)
      return _ChooseCurrencyMenu();
    else if (invoice.isExpired())
      return _ExpiredInvoice();
  }

  Widget _InvoiceComponent() {
    return AnimatedOpacity(
      opacity: _invoiceReady ? 1.0 : 0.0,
      duration: Duration(milliseconds: 300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(_successMessage,
            style: TextStyle(color: AppController.green),
          ),
          Visibility(
            visible: _showLinkToWalletHelp,
            child: GestureDetector(
              onTap: _openHelpUrl,
              child: Text('Having trouble paying?',
                style: TextStyle(color: AppController.blue)
              )
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _chooseCurrency,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PaymentTitle(usePayProtocol ? 'anypay' : currency),
                  Visibility(
                    visible: invoice.paymentOptions.length > 1,
                    child: Container(
                      width: 40,
                      height: 42,
                      margin: EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.expand_more, size: 50)
                    )
                  )
                ]
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 12.0,
                color: qrColor,
              ),
              borderRadius: BorderRadius.all(Radius.circular(18.0)),
            ),
            child: Container(
              color: AppController.white,
              margin: EdgeInsets.all(12.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleUrlStyle,
                child: QrImage(
                  foregroundColor: Color(0xFF404040),
                  version: QrVersions.auto,
                  size: AppController.scale(200, maxValue: 280, minValue: 100),
                  data: uri,
                ),
              ),
            ),
          ),
          (sharePlacement = RectGetter.defaultKey(
            child: Container(
              width: 235,
              margin: EdgeInsets.only(top: AppController.scale(20.0)),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _shareUri,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Share Payment Request',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      )
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15),
                      child: Image(
                          image: AppController.enableDarkMode ?
                            AssetImage('assets/images/share-white.png') :
                            AssetImage('assets/images/share.png'),
                        width: 20,
                      )
                    )
                  ]
                )
              )
            )
          )),
          Container(
            width: 300,
            height: 200,
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: 300,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Container(
                )
              )
            )
          )
        ]
      )
    );
  }

  Widget _BackButton({margin}) {
    var onTap;
    if (choosingCurrency)
      onTap = () {
        choosingCurrency = false;
        _rebuild();
      };
    return Visibility(
      visible: invoice == null || (!invoice.isExpired() && invoice.isUnpaid()) || invoice.isUnderpaid(),
      child: CircleBackButton(
        margin: margin ?? EdgeInsets.only(top: AppController.scale(15.0), bottom: 20.0),
        backPath: backPath,
        opaque: false,
        onTap: onTap,
      )
    );
  }

  void _closeKeyboard() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus)
      currentFocus.unfocus();
  }
}


