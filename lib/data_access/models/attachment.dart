class Attachment {
  String? id;
  String? label;
  String? originalFileName;
  String? downloadUrl;
  String? viewableAttachmentType;

  Attachment(
      {this.id,
      this.label,
      this.originalFileName,
      this.downloadUrl,
      this.viewableAttachmentType});

  Attachment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    label = json['label'];
    originalFileName = json['originalFileName'];
    downloadUrl = json['downloadUrl'];
    viewableAttachmentType = json['viewableAttachmentType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['label'] = this.label;
    data['originalFileName'] = this.originalFileName;
    data['downloadUrl'] = this.downloadUrl;
    data['viewableAttachmentType'] = this.viewableAttachmentType;
    return data;
  }
}
