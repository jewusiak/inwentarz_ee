import 'package:flutter/material.dart';
import 'package:inwentarz_ee/data_access/models/attachment.dart';
import 'package:inwentarz_ee/data_access/models/user_profile.dart';

enum EventType { COMMENT, CALIBRATION, REPAIR, BREAKDOWN }

extension EventTypeExtension on EventType {
  String get polishName {
    switch (this) {
      case EventType.COMMENT:
        return "Komentarz";
      case EventType.CALIBRATION:
        return "Kalibracja";
      case EventType.REPAIR:
        return "Naprawa";
      case EventType.BREAKDOWN:
        return "Uszkodzenie";
      default:
        return "Nieznany";
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.COMMENT:
        return Icons.comment;
      case EventType.CALIBRATION:
        return Icons.compass_calibration;
      case EventType.REPAIR:
        return Icons.build;
      case EventType.BREAKDOWN:
        return Icons.priority_high;
      default:
        return Icons.question_mark;
    }
  }
}

class Event {
  late int id;
  String? dateCreated;
  UserProfile? createdBy;
  String? comment;
  EventType? eventType;
  List<Attachment>? attachments;

  Event(
      {required this.id,
      this.dateCreated,
      this.createdBy,
      this.comment,
      this.eventType,
      this.attachments});

  Event.fromJson(Map<String, dynamic> json) {
    id = json['id']!;
    dateCreated = json['dateCreated'];
    createdBy = json['createdBy'] != null
        ? new UserProfile.fromJson(json['createdBy'])
        : null;
    comment = json['comment'];
    eventType = EventType.values.byName(json['eventType']!);
    if (json['attachments'] != null) {
      attachments = <Attachment>[];
      json['attachments'].forEach((v) {
        attachments!.add(new Attachment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['dateCreated'] = this.dateCreated;
    if (this.createdBy != null) {
      data['createdBy'] = this.createdBy!.toJson();
    }
    data['comment'] = this.comment;
    data['eventType'] = this.eventType;
    if (this.attachments != null) {
      data['attachments'] = this.attachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
