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
import 'package:dinomail_app/models/VirtualDomain.dart';
import 'package:dinomail_app/api.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:dinomail_app/utils.dart';
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VirtualDomainsScreen extends StatefulWidget {
  @override
  createState() => _VirtualDomainsScreen();
}

class _VirtualDomainsScreen extends State {
  List<VirtualDomain> virtualdomains = <VirtualDomain>[];
  var api = API();
  final _biggerFont = const TextStyle(fontSize: 18.0);
  bool _isInAsyncCall = true;

  _getVirtualDomains() async {
    await api.init();
    api.getVirtualDomains().then((response) {
      setState(() {
        if (response.statusCode == 200) {
          var parsedJson = json.decode(response.body);
          Iterable list = parsedJson["objects"];
          virtualdomains =
              list.map((model) => VirtualDomain.fromJson(model)).toList();
        }
        _isInAsyncCall = false;
      });
    });
  }

  Future<void> _refreshVirtualDomains() async {
    api.getVirtualDomains().then((response) {
      setState(() {
        var parsedJson = json.decode(response.body);
        Iterable list = parsedJson["objects"];
        virtualdomains =
            list.map((model) => VirtualDomain.fromJson(model)).toList();
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
      appBar: AppBar(title: Text("Virtual domains")),
      body: RefreshIndicator(
        child: ModalProgressHUD(
          inAsyncCall: _isInAsyncCall,
          opacity: 0.5,
          progressIndicator: CircularProgressIndicator(),
          child: ListView.builder(
            itemCount: virtualdomains.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(virtualdomains[index].name, style: _biggerFont),
                subtitle: Text('DKIM : ' +
                    virtualdomains[index].readableDkim() +
                    ' - DMARC : ' +
                    virtualdomains[index].readableDmarc() +
                    ' - SPF : ' +
                    virtualdomains[index].readableSPF()),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red, size: 25),
                  onPressed: () {
                    Widget continueButton = TextButton(
                      child: Text("Delete"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        api.deleteVirtualDomain(virtualdomains[index].id);
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("Domain deleted.")));
                        setState(() {
                          virtualdomains.removeAt(index);
                        });
                      },
                    );
                    showDeleteAlertDialog(
                        context,
                        virtualdomains[index].name,
                        "Delete domain",
                        "Are you sure you want to delete the domain " +
                            virtualdomains[index].name +
                            " ?",
                        continueButton);
                  },
                ),
                onTap: () {
                  Navigator.pushNamed(context, "/virtualdomains/edit",
                          arguments: EditVirtualDomainsArguments(
                              virtualdomains[index]))
                      .then((value) => _refreshVirtualDomains());
                },
              );
            },
          ),
        ),
        onRefresh: _refreshVirtualDomains,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/virtualdomains/create")
              .then((value) => _refreshVirtualDomains());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class AddVirtualDomainScreen extends StatefulWidget {
  @override
  createState() => _AddVirtualDomainScreen();
}

class _AddVirtualDomainScreen extends State {
  var api = API();
  final _formKey = GlobalKey<FormState>();
  VirtualDomain vd = new VirtualDomain(0, "", 0, 0, 0);

  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add virtual domain'),
        ),
        body: Form(
            key: _formKey,
            child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(FontAwesomeIcons.globe),
                      hintText: 'Enter domain name (e.g. example.com)',
                      labelText: 'Name',
                    ),
                    validator: (val) => val.isEmpty ? 'Name is required' : null,
                    onSaved: (val) => vd.name = val,
                  ),
                  new Container(
                      padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                      child: new ElevatedButton(
                        child: const Text('Submit'),
                        onPressed: _submitForm,
                      )),
                ])));
  }

  void _submitForm() async {
    await api.init();
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      api.createVirtualDomain(vd);
      Navigator.pop(context);
    }
  }
}

class EditVirtualDomainsArguments {
  final VirtualDomain vd;

  EditVirtualDomainsArguments(this.vd);
}

class EditVirtualDomainScreen extends StatefulWidget {
  @override
  createState() => _EditVirtualDomainScreen();
}

class _EditVirtualDomainScreen extends State {
  var api = API();
  final _formKey = GlobalKey<FormState>();
  VirtualDomain vd;

  initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  build(context) {
    final EditVirtualDomainsArguments args =
        ModalRoute.of(context).settings.arguments;
    vd = args.vd;
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit virtual domain'),
        ),
        body: Form(
            key: _formKey,
            child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      icon: const Icon(FontAwesomeIcons.globe),
                      hintText: 'Enter domain name (e.g. example.com)',
                      labelText: 'Name',
                    ),
                    initialValue: vd.name,
                    validator: (val) => val.isEmpty ? 'Name is required' : null,
                    onSaved: (val) => vd.name = val,
                  ),
                  new Container(
                      padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                      child: new ElevatedButton(
                        child: const Text('Submit'),
                        onPressed: _submitForm,
                      )),
                ])));
  }

  void _submitForm() async {
    await api.init();
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      api.updateVirtualDomain(vd);
      Navigator.pop(context);
    }
  }
}
