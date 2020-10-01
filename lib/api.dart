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

import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dinomail_app/models/VirtualDomain.dart';
import 'package:dinomail_app/models/VirtualUser.dart';
import 'package:dinomail_app/models/VirtualAlias.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class API {
  String baseUrl;
  String username;
  String apiKey;
  String authorization;

  API();

  init() async {
    SharedPreferences.getInstance().then((prefs) {
        baseUrl = prefs.getString('url') + '/api';
        username = prefs.getString('username');
        apiKey = prefs.getString('token');
        authorization = "ApiKey " + username + ":" + apiKey;
    });
  }

  Future getToken(String baseUrl, String username, String password) {
    var url = baseUrl + "/api/apikey/";
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    return http.get(url, headers: {HttpHeaders.authorizationHeader: basicAuth});
  }

  Future getVirtualDomains() {
    var url = baseUrl + "/virtualdomain/";
    return http
        .get(url, headers: {HttpHeaders.authorizationHeader: authorization});
  }

  Future getVirtualUsers() {
    var url = baseUrl + "/virtualuser/";
    return http
        .get(url, headers: {HttpHeaders.authorizationHeader: authorization});
  }

  Future getVirtualAliases() {
    var url = baseUrl + "/virtualalias/";
    return http
        .get(url, headers: {HttpHeaders.authorizationHeader: authorization});
  }

  void createVirtualDomain(VirtualDomain virtualDomain) {
    var url = baseUrl + "/virtualdomain/";
    http.post(url,
        headers: {
          HttpHeaders.authorizationHeader: authorization,
          HttpHeaders.contentTypeHeader: 'application/json; CHARSET=UTF-8'
        },
        body: jsonEncode(virtualDomain.toJson()));
  }

  void updateVirtualDomain(VirtualDomain virtualDomain) {
    var url = baseUrl + "/virtualdomain/" + virtualDomain.id.toString() + "/";
    http.patch(url,
        headers: {
          HttpHeaders.authorizationHeader: authorization,
          HttpHeaders.contentTypeHeader: 'application/json; CHARSET=UTF-8'
        },
        body: jsonEncode(virtualDomain.toJson()));
  }

  void deleteVirtualDomain(int pk) {
    var url = baseUrl + "/virtualdomain/" + pk.toString() + "/";
    http.delete(url, headers: {HttpHeaders.authorizationHeader: authorization});
  }

  void createVirtualUser(VirtualUser virtualUser) {
    var url = baseUrl + "/virtualuser/";
    http.post(url,
        headers: {
          HttpHeaders.authorizationHeader: authorization,
          HttpHeaders.contentTypeHeader: 'application/json; CHARSET=UTF-8'
        },
        body: jsonEncode(virtualUser.toJson()));
  }

  void updateVirtualUser(VirtualUser virtualUser) {
    var url = baseUrl + "/virtualuser/" + virtualUser.id.toString() + "/";
    http.patch(url,
        headers: {
          HttpHeaders.authorizationHeader: authorization,
          HttpHeaders.contentTypeHeader: 'application/json; CHARSET=UTF-8'
        },
        body: jsonEncode(virtualUser.toJson()));
  }

   void updateVirtualUserPassword(VirtualUser virtualUser, String password) {
    var url = baseUrl + "/changeuserpassword/" + virtualUser.id.toString() + "/";
    http.patch(url,
        headers: {
          HttpHeaders.authorizationHeader: authorization,
          HttpHeaders.contentTypeHeader: 'application/json; CHARSET=UTF-8'
        },
        body: jsonEncode({"password": password}));
  }

  void deleteVirtualUser(int pk) {
    var url = baseUrl + "/virtualuser/" + pk.toString() + "/";
    http.delete(url, headers: {HttpHeaders.authorizationHeader: authorization});
  }

  void createVirtualAlias(VirtualAlias virtualAlias) {
    var url = baseUrl + "/virtualalias/";
    http.post(url,
        headers: {
          HttpHeaders.authorizationHeader: authorization,
          HttpHeaders.contentTypeHeader: 'application/json; CHARSET=UTF-8'
        },
        body: jsonEncode(virtualAlias.toJson()));
  }

  void updateVirtualAlias(VirtualAlias virtualAlias) {
    var url = baseUrl + "/virtualalias/" + virtualAlias.id.toString() + "/";
    http.patch(url,
        headers: {
          HttpHeaders.authorizationHeader: authorization,
          HttpHeaders.contentTypeHeader: 'application/json; CHARSET=UTF-8'
        },
        body: jsonEncode(virtualAlias.toJson()));
  }

  void deleteVirtualAlias(int pk) {
    var url = baseUrl + "/virtualalias/" + pk.toString() + "/";
    http.delete(url, headers: {HttpHeaders.authorizationHeader: authorization});
  }
}
