import 'package:inwentarz_ee/data_access/models/attachment.dart';
import 'package:inwentarz_ee/data_access/models/event.dart';

class Equipment {
  late int id;
  String? name;
  String? location;
  String? description;
  String? nextCalibration;
  List<Attachment>? attachments;
  List<Event>? events;

  Equipment(
      {required this.id,
      this.name,
      this.location,
      this.description,
      this.nextCalibration,
      this.attachments,
      this.events});

  Equipment.fromJson(Map<String, dynamic> json) {
    id = json['id']!;
    name = json['name'];
    location = json['location'];
    description = json['description'];
    nextCalibration = json['nextCalibration'];
    if (json['attachments'] != null) {
      attachments = <Attachment>[];
      json['attachments'].forEach((v) {
        attachments!.add(new Attachment.fromJson(v));
      });
    }
    if (json['events'] != null) {
      events = <Event>[];
      json['events'].forEach((v) {
        events!.add(new Event.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['location'] = this.location;
    data['description'] = this.description;
    data['nextCalibration'] = this.nextCalibration;
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    if (this.events != null) {
      data['events'] = this.events!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
