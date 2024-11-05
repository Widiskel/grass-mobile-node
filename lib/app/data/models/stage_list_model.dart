class StageListModel {
  Result? result;

  StageListModel({this.result});

  StageListModel.fromJson(Map<String, dynamic> json) {
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
  List<StageModel>? data;

  Result({this.data});

  Result.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <StageModel>[];
      json['data'].forEach((v) {
        data!.add(StageModel.fromJson(v));
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

class StageModel {
  String? stageId;
  String? stageName;
  String? entity;
  List<String>? epochs;

  StageModel({this.stageId, this.stageName, this.entity, this.epochs});

  StageModel.fromJson(Map<String, dynamic> json) {
    stageId = json['stageId'];
    stageName = json['stageName'];
    entity = json['entity'];
    epochs = json['epochs'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stageId'] = stageId;
    data['stageName'] = stageName;
    data['entity'] = entity;
    data['epochs'] = epochs;
    return data;
  }
}
