class ApiResponse<T> {
  int? status;
  T? res;

  ApiResponse({this.status, this.res});

  ApiResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    res = json['res'] as T?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (res != null) {
      data['res'] = res;
    }
    return data;
  }
}
