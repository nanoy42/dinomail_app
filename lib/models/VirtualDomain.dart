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

class VirtualDomain {
  int id;
  String name;

  VirtualDomain(int id, String name) {
    this.id = id;
    this.name = name;
  }

  VirtualDomain.fromJson(Map json)
      : id = json["id"],
        name = json['name'];

  Map toJson() {
    return {'name': name};
  }

  String toString() {
    return name;
  }
}
