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
import 'package:dinomail_app/models/VirtualAlias.dart';
import 'package:dinomail_app/models/VirtualDomain.dart';
import 'package:dinomail_app/api.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:dinomail_app/utils.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VirtualAliasesScreen extends StatefulWidget {
  @override
  createState() => _VirtualAliasesScreen();
}

class _VirtualAliasesScreen extends State {
  var virtualaliases = new List<VirtualAlias>();
  var api = API();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool _isInAsyncCall = true;

  _getVirtualAliases() async {
    await api.init();
    api.getVirtualAliases().then((response) {
      setState(() {
        var parsedJson = json.decode(response.body);
        Iterable list = parsedJson["objects"];
        virtualaliases =
            list.map((model) => VirtualAlias.fromJson(model)).toList();
        _isInAsyncCall = false;
      });
    });
  }

  Future<void> _refreshVirtualAliases() async {
    await api.init();
    api.getVirtualAliases().then((response) {
      setState(() {
        var parsedJson = json.decode(response.body);
        Iterable list = parsedJson["objects"];
        virtualaliases =
            list.map((model) => VirtualAlias.fromJson(model)).toList();
      });
    });
  }

  initState() {
    super.initState();
    _getVirtualAliases();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    return Scaffold(
      appBar: AppBar(title: Text("Virtual aliases")),
      body: RefreshIndicator(
        child: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
          child: ListView.builder(
            itemCount: virtualaliases.length,
            itemBuilder: (context, index) {
              return ListTile(
                title:
                    Text(virtualaliases[index].toString(), style: _biggerFont),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red, size: 25),
                  onPressed: () {
                    Widget continueButton = FlatButton(
                      child: Text("Delete"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        api.deleteVirtualAlias(virtualaliases[index].id);
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("Alias deleted.")));
                        setState(() {
                          virtualaliases.removeAt(index);
                        });
                      },
                    );
                    showDeleteAlertDialog(
                        context,
                        virtualaliases[index].toString(),
                        "Delete alias",
                        "Are you sure you want to delete the alias " +
                            virtualaliases[index].toString() +
                            " ?",
                        continueButton);
                  },
                ),
                onTap: () {
                  Navigator.pushNamed(context, "/virtualaliases/edit",
                      arguments:
                          EditVirtualAliasArguments(virtualaliases[index]));
                },
              );
            },
          ),
        ),
        onRefresh: _refreshVirtualAliases,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/virtualaliases/create")
              .then((value) => _refreshVirtualAliases());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class AddVirtualAliasScreen extends StatefulWidget {
  @override
  createState() => _AddVirtualAliasScreen();
}

class _AddVirtualAliasScreen extends State {
  var api = API();
  final _formKey = GlobalKey<FormState>();
  VirtualAlias va = new VirtualAlias(0, "", "", "");
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
        title: Text('Add virtual alias'),
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
                        hintText: 'Enter source (e.g. me@example.com)',
                        labelText: 'Source',
                      ),
                      validator: (val) =>
                          val.isEmpty ? 'Source is required' : null,
                      onSaved: (val) => va.source = val,
                    ),
                    new TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(FontAwesomeIcons.envelope),
                        hintText: 'Enter destination (e.g. me@example.org)',
                        labelText: 'Destination',
                      ),
                      validator: (val) =>
                          val.isEmpty ? 'Destination is required' : null,
                      onSaved: (val) => va.destination = val,
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
          va.domain =
              "/api/virtualdomain/" + virtualdomains[i].id.toString() + "/";
        }
      }
      api.createVirtualAlias(va);
      Navigator.pop(context);
    }
  }
}

class EditVirtualAliasArguments {
  final VirtualAlias va;

  EditVirtualAliasArguments(this.va);
}

class EditVirtualAliasScreen extends StatefulWidget {
  @override
  createState() => _EditVirtualAliasScreen();
}

class _EditVirtualAliasScreen extends State {
  var api = API();
  final _formKey = GlobalKey<FormState>();
  VirtualAlias va;
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
          if (virtualdomains[i].id == va.getDomainId()) {
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
    final EditVirtualAliasArguments args =
        ModalRoute.of(context).settings.arguments;
    va = args.va;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit virtual alias'),
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
                        hintText: 'Enter source (e.g. me@example.com)',
                        labelText: 'Source',
                      ),
                      initialValue: va.source,
                      validator: (val) =>
                          val.isEmpty ? 'Source is required' : null,
                      onSaved: (val) => va.source = val,
                    ),
                    new TextFormField(
                      decoration: const InputDecoration(
                        icon: const Icon(FontAwesomeIcons.envelope),
                        hintText: 'Enter destination (e.g. me@example.org)',
                        labelText: 'Destination',
                      ),
                      initialValue: va.destination,
                      validator: (val) =>
                          val.isEmpty ? 'Destination is required' : null,
                      onSaved: (val) => va.destination = val,
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
          va.domain =
              "/api/virtualdomain/" + virtualdomains[i].id.toString() + "/";
        }
      }
      api.updateVirtualAlias(va);
      Navigator.pop(context);
    }
  }
}
