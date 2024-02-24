import 'package:app/authentication.dart';
import 'package:flutter/material.dart';
import 'package:app/back_button.dart';
import 'package:app/app_controller.dart';
import 'package:app/currencies.dart';
import '../client.dart';
import '../native_storage.dart';

class EditBackEndUrl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EditUrlPage(title: "Edit Url");
  }
}

class EditUrlPage extends StatefulWidget {
  EditUrlPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _EditUrlPageState createState() => _EditUrlPageState();
}

class _EditUrlPageState extends State<EditUrlPage> {
  var _successMessage = '';

  var denomination;

  var symbol;

  var urlController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey();

  bool? isUserLoggedIn;

  @override
  void initState() {
    _rebuild();
    super.initState();
    setBackendUrl();
    isUserLoggedIn = Authentication.currentAccount.email != null;
    if (isUserLoggedIn == true) {
      Authentication.getAccount().then((account) {
        _rebuild();
      });
    }
  }

  void setBackendUrl() {
    urlController.text = Client.apiUri.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _successMessage,
                style: TextStyle(color: AppController.green),
              ),
              Container(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _EditUrlLink(),
                      CircleBackButton(
                        margin: EdgeInsets.only(top: 20.0),
                        backPath: 'navigation',
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _EditUrlLink() {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                controller: urlController,
                decoration: InputDecoration(
                    labelText: 'Update Backend Url',
                    hintText: "http:// or https://"),
                validator: (value) {
                  if (value != null && Uri.parse(value).isAbsolute) {
                    return null;
                  } else {
                    return "Please provide valid url";
                  }
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    showAlertDialog(
                        context: context,
                        title: "Confirmation",
                        desc: isUserLoggedIn == true
                            ? "You will be logged out because you changed the API backend url"
                            : "Are you sure you want to change the backend API url?",
                        onOkPressed: () async {
                          await Storage.write(
                              "backend_url", urlController.text);
                          setState(() {
                            Client.updateUri(
                                uri: Uri.parse(urlController.text));
                          });
                          if (isUserLoggedIn == true) {
                            Authentication.logout();
                          } else {
                            AppController.closeUntilPath('/login');
                          }
                        });
                  }
                },
                child: Text(
                  "Save",
                )),
          )
        ],
      ),
    );
  }

  void _rebuild() {
    setState(() {
      if (Authentication.currentAccount.denomination != null) {
        denomination = Authentication.currentAccount.denomination;
        symbol = Currencies.all[denomination]!['symbol'];
      } else {
        denomination = 'USD';
        symbol = '\$';
      }
    });
  }

  showAlertDialog(
      {required BuildContext context,
      required String title,
      required String desc,
      required onOkPressed}) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: onOkPressed,
    );
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(title,
          style: TextStyle(
              color:
                  AppController.enableDarkMode ? Colors.white : Colors.black)),
      content: Text(desc),
      actions: [
        cancelButton,
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
