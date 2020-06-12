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

class VirtualAlias {
  int id;
  String source;
  String destination;
  String domain;

  VirtualAlias(int id, String source, String destination, String domain) {
    this.id = id;
    this.source = source;
    this.destination = destination;
    this.domain = domain;
  }

  VirtualAlias.fromJson(Map json)
      : id = json['id'],
        source = json['source'],
        destination = json['destination'],
        domain = json['domain'];

  Map toJson() {
    return {'source': source, 'destination': destination, "domain": domain};
  }

  String toString() {
    return source + " -> " + destination;
  }

  num getDomainId() {
    // /api/virtualdomain/pk/ -> 19, length-1
    return num.parse(domain.substring(19, domain.length - 1));
  }
}
