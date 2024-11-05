class PublicIpModel {
  String? ip;

  PublicIpModel({this.ip});

  PublicIpModel.fromJson(Map<String, dynamic> json) {
    ip = json['ip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ip'] = ip;
    return data;
  }
}
