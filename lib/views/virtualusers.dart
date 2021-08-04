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

import 'package:flutter/material.dart';
import 'package:dinomail_app/models/VirtualUser.dart';
import 'package:dinomail_app/models/VirtualDomain.dart';
import 'package:dinomail_app/api.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:dinomail_app/utils.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';

class VirtualUsersScreen extends StatefulWidget {
  @override
  createState() => _VirtualUsersScreen();
}

class _VirtualUsersScreen extends State {
  var virtualusers = new List<VirtualUser>();
  var api = API();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool _isInAsyncCall = true;

  _getVirtualUsers() async {
    await api.init();
    api.getVirtualUsers().then((response) {
      setState(() {
        var parsedJson = json.decode(response.body);
        Iterable list = parsedJson["objects"];
        virtualusers =
            list.map((model) => VirtualUser.fromJson(model)).toList();
        _isInAsyncCall = false;
      });
    });
  }

  Future<void> _refreshVirtualUsers() async {
    api.getVirtualUsers().then((response) {
      setState(() {
        var parsedJson = json.decode(response.body);
        Iterable list = parsedJson["objects"];
        virtualusers =
            list.map((model) => VirtualUser.fromJson(model)).toList();
      });
    });
  }

  initState() {
    super.initState();
    _getVirtualUsers();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    return Scaffold(
      appBar: AppBar(title: Text("Virtual users")),
      body: RefreshIndicator(
        child: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
          child: ListView.builder(
            itemCount: virtualusers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(virtualusers[index].email, style: _biggerFont),
                subtitle:
                    Text('Quota : ' + virtualusers[index].readableQuota()),
                trailing:
                    Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.lock, color: Colors.blue, size: 25),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, "/virtualusers/editPassword",
                            arguments:
                                EditPasswordArguments(virtualusers[index]));
                      }),
                  IconButton(
                    icon:
                        Icon(Icons.delete_outline, color: Colors.red, size: 25),
                    onPressed: () {
                      Widget continueButton = FlatButton(
                        child: Text("Delete"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          api.deleteVirtualUser(virtualusers[index].id);
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text("User deleted.")));
                          setState(() {
                            virtualusers.removeAt(index);
                          });
                        },
                      );
                      showDeleteAlertDialog(
                          context,
                          virtualusers[index].email,
                          "Delete user",
                          "Are you sure you want to delete the user " +
                              virtualusers[index].email +
                              " ?",
                          continueButton);
                    },
                  )
                ]),
                onTap: () {
                  Navigator.pushNamed(context, "/virtualusers/edit",
                          arguments:
                              EditVirtualUserArguments(virtualusers[index]))
                      .then((value) => _refreshVirtualUsers());
                },
              );
            },
          ),
        ),
        onRefresh: _refreshVirtualUsers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/virtualusers/create")
              .then((value) => _refreshVirtualUsers());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class AddVirtualUserScreen extends StatefulWidget {
  @override
  createState() => _AddVirtualUserScreen();
}

class _AddVirtualUserScreen extends State {
  var api = API();
  final _formKey = GlobalKey<FormState>();
  VirtualUser vu = new VirtualUser(0, "", 0, "");
  List<String> _domains = <String>[''];
  List<VirtualDomain> virtualdomains;
  String _domain = '';
  bool _isInAsyncCall = true;

  _getVirtualDomains() async {
    await api.init();
    api.getVirtualDomains().then((response) {
      setState(() {
        var parsedJson = json.decode(response.body);
        Iterable list = parsedJson["objects"];
        virtualdomains =
            list.map((model) => VirtualDomain.fromJson(model)).toList();
        _domains = [''] + virtualdomains.map((model) => model.name).toList();
        _isInAsyncCall = false;
      });
    });
  }

  initState() {
    super.initState();
    _getVirtualDomains();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add virtual user'),
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
                    new FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            icon: const Icon(FontAwesomeIcons.globe),
                            labelText: 'Domain',
                          ),
                          isEmpty: _domain == '',
                          child: new DropdownButtonHideUnderline(
                            child: new DropdownButton<String>(
                              value: _domain,
                              isDense: true,
                              onChanged: (String newValue) {
                                setState(() {
                                  _domain = newValue;
                                  state.didChange(newValue);
                                });
                              },
                              items: _domains.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    new TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(FontAwesomeIcons.envelope),
                        hintText: 'Enter user email (e.g. me@example.com)',
                        labelText: 'Email',
                      ),
                      validator: (val) =>
                          val.isEmpty ? 'Email is required' : null,
                      onSaved: (val) => vu.email = val,
                    ),
                    new TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(FontAwesomeIcons.batteryHalf),
                        hintText: 'Enter quota in bytes',
                        labelText: 'Quota',
                      ),
                      validator: (val) =>
                          val.isEmpty ? 'Quota is required' : null,
                      onSaved: (val) => vu.quota = num.parse(val),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                    ),
                    new Container(
                        padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                        child: new RaisedButton(
                          child: const Text('Submit'),
                          onPressed: _submitForm,
                        )),
                  ]))),
    );
  }

  void _submitForm() async {
    await api.init();
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      for (var i = 0; i < virtualdomains.length; i++) {
        if (virtualdomains[i].name == _domain) {
          vu.domain =
              "/api/virtualdomain/" + virtualdomains[i].id.toString() + "/";
        }
      }
      api.createVirtualUser(vu);
      Navigator.pop(context);
    }
  }
}

class EditVirtualUserArguments {
  final VirtualUser vu;

  EditVirtualUserArguments(this.vu);
}

class EditVirtualUsersScreen extends StatefulWidget {
  @override
  createState() => _EditVirtualUserScreen();
}

class _EditVirtualUserScreen extends State {
  var api = API();
  final _formKey = GlobalKey<FormState>();
  VirtualUser vu;
  List<String> _domains = <String>[''];
  List<VirtualDomain> virtualdomains;
  String _domain = '';
  bool _isInAsyncCall = true;

  _getVirtualDomains() async {
    await api.init();
    api.getVirtualDomains().then((response) {
      setState(() {
        var parsedJson = json.decode(response.body);
        Iterable list = parsedJson["objects"];
        virtualdomains =
            list.map((model) => VirtualDomain.fromJson(model)).toList();
        _domains = [''] + virtualdomains.map((model) => model.name).toList();
        for (var i = 0; i < virtualdomains.length; i++) {
          if (virtualdomains[i].id == vu.getDomainId()) {
            _domain = virtualdomains[i].name;
          }
        }
        _isInAsyncCall = false;
      });
    });
  }

  initState() {
    super.initState();
    _getVirtualDomains();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    final EditVirtualUserArguments args =
        ModalRoute.of(context).settings.arguments;
    vu = args.vu;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit virtual user'),
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
                    new FormField<String>(
                      builder: (FormFieldState<String> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            icon: const Icon(FontAwesomeIcons.globe),
                            labelText: 'Domain',
                          ),
                          isEmpty: _domain == '',
                          child: new DropdownButtonHideUnderline(
                            child: new DropdownButton<String>(
                              value: _domain,
                              isDense: true,
                              onChanged: (String newValue) {
                                setState(() {
                                  _domain = newValue;
                                  state.didChange(newValue);
                                });
                              },
                              items: _domains.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                    new TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(FontAwesomeIcons.envelope),
                        hintText: 'Enter user email (e.g. me@example.com)',
                        labelText: 'Email',
                      ),
                      initialValue: vu.email,
                      validator: (val) =>
                          val.isEmpty ? 'Email is required' : null,
                      onSaved: (val) => vu.email = val,
                    ),
                    new TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(FontAwesomeIcons.batteryHalf),
                        hintText: 'Enter quota in bytes',
                        labelText: 'Quota',
                      ),
                      initialValue: vu.quota.toString(),
                      validator: (val) =>
                          val.isEmpty ? 'Quota is required' : null,
                      onSaved: (val) => vu.quota = num.parse(val),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                    ),
                    new Container(
                        padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                        child: new RaisedButton(
                          child: const Text('Submit'),
                          onPressed: _submitForm,
                        )),
                  ]))),
    );
  }

  void _submitForm() async {
    await api.init();
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      for (var i = 0; i < virtualdomains.length; i++) {
        if (virtualdomains[i].name == _domain) {
          vu.domain =
              "/api/virtualdomain/" + virtualdomains[i].id.toString() + "/";
        }
      }
      api.updateVirtualUser(vu);
      Navigator.pop(context);
    }
  }
}

class EditPasswordArguments {
  final VirtualUser vu;

  EditPasswordArguments(this.vu);
}

class EditPasswordScreen extends StatefulWidget {
  @override
  createState() => _EditPasswordScreen();
}

class _EditPasswordScreen extends State {
  var api = API();
  final _formKey = GlobalKey<FormState>();
  VirtualUser vu;
  String password;

  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    final EditPasswordArguments args =
        ModalRoute.of(context).settings.arguments;
    vu = args.vu;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit virtual user\'s passowrd'),
      ),
      body: Form(
          key: _formKey,
          child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
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
                    child: new RaisedButton(
                      child: const Text('Submit'),
                      onPressed: _submitForm,
                    )),
              ])),
    );
  }

  void _submitForm() async {
    await api.init();
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      api.updateVirtualUserPassword(vu, password);
      Navigator.pop(context);
    }
  }
}
