class NodeData {
  bool? isConnected;
  bool? isConnecting;
  String? statusText;
  String? deviceIp;
  int? networkScore;

  NodeData(
      {this.isConnected,
      this.isConnecting,
      this.statusText,
      this.deviceIp,
      this.networkScore});

  NodeData.fromJson(Map<String, dynamic> json) {
    isConnected = json['isConnected'];
    isConnecting = json['isConnecting'];
    statusText = json['statusText'];
    deviceIp = json['deviceIp'];
    networkScore = json['networkScore'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isConnected'] = isConnected;
    data['isConnecting'] = isConnecting;
    data['statusText'] = statusText;
    data['deviceIp'] = deviceIp;
    data['networkScore'] = networkScore;
    return data;
  }
}
