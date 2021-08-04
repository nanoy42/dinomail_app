/*
DinoMail App - Hungry dino managing emails on smartphone
Copyright (C) 2020 Yoann Pietri

DinoMail App is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

DinoMail App is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with DinoMail App. If not, see <https://www.gnu.org/licenses/>.
*/

import 'package:dinomail_app/api.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dinomail_app/views/virtualdomains.dart';
import 'package:dinomail_app/views/virtualusers.dart';
import 'package:dinomail_app/views/virtualaliases.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  build(context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DinoMail',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/virtualdomains': (context) => VirtualDomainsScreen(),
        '/virtualdomains/create': (context) => AddVirtualDomainScreen(),
        '/virtualdomains/edit': (context) => EditVirtualDomainScreen(),
        '/virtualusers': (context) => VirtualUsersScreen(),
        '/virtualusers/create': (context) => AddVirtualUserScreen(),
        '/virtualusers/edit': (context) => EditVirtualUsersScreen(),
        '/virtualusers/editPassword': (context) => EditPasswordScreen(),
        '/virtualaliases': (context) => VirtualAliasesScreen(),
        '/virtualaliases/create': (context) => AddVirtualAliasScreen(),
        '/virtualaliases/edit': (context) => EditVirtualAliasScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends State {
  String url;
  String username;
  String tokem;

  initState() {
    super.initState();
    _getPreferences();
  }

  dispose() {
    super.dispose();
  }

  _getPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool check = prefs.containsKey('url') &
        prefs.containsKey('username') &
        prefs.containsKey('token');
    if (!check) {
      Navigator.pushNamed(context, '/settings');
    }
  }

  @override
  build(context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("DinoMail"),
        ),
        body: new Container(
            child: new ListView(
          children: <Widget>[
            Card(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: new Column(children: <Widget>[
                      new Image.asset(
                        'assets/dinomail.jpg',
                        width: 200,
                      ),
                      Text("Welcome to DinoMail",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30)),
                      Text(
                        "DinoMail is an hungry dino managing your emails. You can create, edit and delete virtual domains, users and aliases. It is not possible for now to edit a user's password.",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 10,
                      ),
                    ]))),
            Card(
                child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Navigator.pushNamed(context, '/virtualdomains');
                    },
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new Column(children: <Widget>[
                          new Icon(FontAwesomeIcons.globe, size: 100),
                          SizedBox(height: 20),
                          Text("Virtual domains",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30)),
                        ])))),
            Card(
                child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Navigator.pushNamed(context, '/virtualusers');
                    },
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new Column(children: <Widget>[
                          new Icon(FontAwesomeIcons.users, size: 100),
                          SizedBox(height: 20),
                          Text("Virtual users",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30)),
                        ])))),
            Card(
                child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Navigator.pushNamed(context, '/virtualaliases');
                    },
                    child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new Column(children: <Widget>[
                          new Icon(FontAwesomeIcons.shareSquare, size: 100),
                          SizedBox(height: 20),
                          Text("Virtual aliases",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30)),
                        ])))),
          ],
        )),
        drawer: Drawer(
            child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          DrawerHeader(
            child: Text(''),
            decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                    image: AssetImage("assets/dinomail.jpg"),
                    fit: BoxFit.cover)),
          ),
          Container(
              padding: EdgeInsets.all(10),
              child: Text("DinoMail",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(
            title: Text('Virtual domains'),
            leading: Icon(FontAwesomeIcons.globe),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/virtualdomains');
            },
          ),
          ListTile(
              title: Text('Virtual users'),
              leading: Icon(FontAwesomeIcons.users),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/virtualusers');
              }),
          ListTile(
              title: Text('Virtual aliases'),
              leading: Icon(FontAwesomeIcons.shareSquare),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/virtualaliases');
              }),
          ListTile(
              title: Text('Settings'),
              leading: Icon(FontAwesomeIcons.cog),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              }),
          Container(
              padding: EdgeInsets.all(10),
              child: Text("v1.0.1",
                  style: TextStyle(fontWeight: FontWeight.bold))),
        ])));
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State {
  String url;
  String username;
  String token;
  String password;
  final _formKey = GlobalKey<FormState>();
  bool _isInAsyncCall = true;
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  String tokenOk;
  API api = API();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  initState() {
    super.initState();
    _getPreferences();
  }

  dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  _getPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        url = prefs.getString('url') ?? "";
        _urlController.text = url;
        username = prefs.getString('username') ?? "";
        _usernameController.text = username;
        token = prefs.getString('token') ?? "";
        _isInAsyncCall = false;
        if (token != "") {
          tokenOk = "Yes";
        } else {
          tokenOk = "No";
        }
      });
    });
  }

  @override
  build(context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: Form(
            key: _formKey,
            child: ModalProgressHUD(
                inAsyncCall: _isInAsyncCall,
                opacity: 0.5,
                progressIndicator: CircularProgressIndicator(),
                child: new ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: <Widget>[
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(FontAwesomeIcons.link),
                          hintText:
                              'Enter URL of dinomail app (without the /api)',
                          labelText: 'URL',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'URL is required' : null,
                        onSaved: (val) => url = val,
                        controller: _urlController,
                      ),
                      new TextFormField(
                        decoration: const InputDecoration(
                          icon: const Icon(FontAwesomeIcons.user),
                          hintText: 'Enter username',
                          labelText: 'Username',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'Username is required' : null,
                        onSaved: (val) => username = val,
                        controller: _usernameController,
                      ),
                      new TextFormField(
                        obscureText: true,
                        decoration: const InputDecoration(
                          icon: const Icon(FontAwesomeIcons.unlock),
                          hintText: 'Enter password',
                          labelText: 'Password',
                        ),
                        validator: (val) =>
                            val.isEmpty ? 'Password is required' : null,
                        onSaved: (val) => password = val,
                      ),
                      new Container(
                          padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                          child: new ElevatedButton(
                            child: const Text('Save'),
                            onPressed: _submitForm,
                          )),
                      new Container(
                          padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                          child: new Text('Token saved : ' + '$tokenOk')),
                      new Container(
                          padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                          child: new ElevatedButton(
                              child: const Text('Delete saved values'),
                              onPressed: _cleanSharedPreferences,
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              ))),
                    ]))));
  }

  _submitForm() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      api.getToken(url, username, password).then((response) {
        setState(() {
          if (response.statusCode == 200) {
            var parsedJson = json.decode(response.body);
            Iterable list = parsedJson["objects"];
            token = list.elementAt(0)["key"];
            tokenOk = "Yes";
            SharedPreferences.getInstance().then((prefs) {
              prefs.remove('url');
              prefs.remove('username');
              prefs.remove('token');
              prefs.setString('url', url);
              prefs.setString('username', username);
              prefs.setString('token', token);
              _scaffoldKey?.currentState?.showSnackBar(SnackBar(
                  content: Text(
                'Preferences updated.',
              )));
            });
          } else {
            _scaffoldKey?.currentState?.showSnackBar(SnackBar(
                content: Text(
              'Username/password incorrect.',
            )));
          }
        });
      });
    }
  }

  _cleanSharedPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('url');
      prefs.remove('username');
      prefs.remove('token');
    });
    setState(() {
      _urlController.text = "";
      _usernameController.text = "";
      tokenOk = "No";
      _scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(
        'Preferences cleaned.',
      )));
    });
  }
}
