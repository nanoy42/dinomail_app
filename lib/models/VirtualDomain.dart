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
  int dkim_status;
  int dmarc_status;
  int spf_status;

  VirtualDomain(int id, String name, int dkim_status, int dmarc_status, int spf_status) {
    this.id = id;
    this.name = name;
    this.dkim_status = dkim_status;
    this.dmarc_status = dmarc_status;
    this.spf_status = spf_status;
  }

  VirtualDomain.fromJson(Map json)
      : id = json["id"],
        name = json['name'],
        dkim_status = json['dkim_status'],
        dmarc_status = json['dmarc_status'],
        spf_status = json['spf_status'];

  Map toJson() {
    return {'name': name, 'dkim_status': dkim_status, 'dmarc_status': dmarc_status, 'spf_status': spf_status};
  }

  String toString() {
    return name;
  }

  String readableDkim(){
    if(dkim_status == 0){
      return "Not set";
    }else if(dkim_status == 1){
      return "DNS record not found";
    }else if(dkim_status == 2){
      return "No DNS key found in record";
    }else if(dkim_status == 3){
      return "Key and DNS record don't match";
    }else{
      return "OK";
    }
  }

  String readableDmarc(){
    if(dmarc_status == 0){
      return "No DNS record for DMARC";
    }else if(dmarc_status == 1){
      return "DNS record does not contain v=DMARC1";
    }else{
      return "OK";
    }
  }

  String readableSPF(){
    if(spf_status == 0){
      return "No DNS record for SPF";
    }else{
      return "OK";
    }
  }
}
