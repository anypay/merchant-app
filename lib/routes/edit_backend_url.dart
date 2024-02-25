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
    return EditBackEndUrlPage(title: "Edit Backend Url");
  }
}

class EditBackEndUrlPage extends StatefulWidget {
  EditBackEndUrlPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _EditBackEndUrlState createState() => _EditBackEndUrlState();
}

class _EditBackEndUrlState extends State<EditBackEndUrlPage> {
  var urlController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey();


  @override
  void initState() {
    super.initState();
    setBackendUrl();
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
      child: Column(
        children: [
          TextFormField(
              controller: urlController,
              decoration: InputDecoration(
                  labelText: 'Backend Url',
                  hintText: "http:// or https://"),
              validator: (value) {
                if (value != null && Uri.parse(value).isAbsolute) {
                  return null;
                } else {
                  return "Please provide valid url";
                }
              }),
          Container(
            margin: EdgeInsets.only(top: 40.0),
            child: GestureDetector(
              child: Text('SAVE', style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppController.blue,
                fontSize: 18,
              )),
              onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    showAlertDialog(
                        context: context,
                        title: "Confirmation",
                        desc: "Are you sure you want to change the backend API url?",
                        onOkPressed: () async {
                          await Storage.write(
                              "backend_url", urlController.text);
                            Client.updateUri(
                                uri: Uri.parse(urlController.text));
                            Authentication.logout();
                        });
                  }
                },
            ),
          ),
        ],
      ),
    );
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
      title: Text(title),
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
