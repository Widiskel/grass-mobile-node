class ActiveDeviceListModel {
  Result? result;

  ActiveDeviceListModel({this.result});

  ActiveDeviceListModel.fromJson(Map<String, dynamic> json) {
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (result != null) {
      data['result'] = result!.toJson();
    }
    return data;
  }
}

class Result {
  List<ActiveDevices>? data;

  Result({this.data});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ActiveDevices>[];
      json['data'].forEach((v) {
        data!.add(ActiveDevices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ActiveDevices {
  String? ipAddress;
  String? modified;
  int? ipScore;
  String? deviceId;
  String? entity;
  String? lastConnectedAt;
  String? userId;
  String? created;
  int? aggUptime;
  double? multiplier;

  ActiveDevices(
      {this.ipAddress,
      this.modified,
      this.ipScore,
      this.deviceId,
      this.entity,
      this.lastConnectedAt,
      this.userId,
      this.created,
      this.aggUptime,
      this.multiplier});

  ActiveDevices.fromJson(Map<String, dynamic> json) {
    ipAddress = json['ipAddress'];
    modified = json['modified'];
    ipScore = json['ipScore'];
    deviceId = json['deviceId'];
    entity = json['entity'];
    lastConnectedAt = json['lastConnectedAt'];
    userId = json['userId'];
    created = json['created'];
    aggUptime = json['aggUptime'];
    multiplier = json['multiplier'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ipAddress'] = ipAddress;
    data['modified'] = modified;
    data['ipScore'] = ipScore;
    data['deviceId'] = deviceId;
    data['entity'] = entity;
    data['lastConnectedAt'] = lastConnectedAt;
    data['userId'] = userId;
    data['created'] = created;
    data['aggUptime'] = aggUptime;
    data['multiplier'] = multiplier;
    return data;
  }
}
