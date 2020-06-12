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

class VirtualUser {
  int id;
  String email;
  num quota;
  String domain;

  VirtualUser(int id, String email, num quota, String domain) {
    this.id = id;
    this.email = email;
    this.quota = quota;
    this.domain = domain;
  }

  VirtualUser.fromJson(Map json)
      : id = json["id"],
        email = json["email"],
        quota = json["quota"],
        domain = json["domain"];

  Map toJson() {
    return {'email': email, 'quota': quota, "domain": domain};
  }

  String readableQuota() {
    String res;
    if (quota < 1000) {
      res = quota.toString() + " B";
    } else if (quota < 1000000) {
      num dividedQuota = quota ~/ 1000;
      res = dividedQuota.toString() + " kB";
    } else if (quota < 1000000000) {
      num dividedQuota = quota ~/ 1000000;
      res = dividedQuota.toString() + " MB";
    } else {
      num dividedQuota = quota ~/ 1000000000;
      res = dividedQuota.toString() + " GB";
    }
    return res;
  }

  String toString() {
    return email;
  }

  num getDomainId() {
    // /api/virtualdomain/pk/ -> 19, length-1
    return num.parse(domain.substring(19, domain.length - 1));
  }
}
