import 'package:dio/dio.dart';
import 'package:grass/app/data/models/api_response.dart';
import 'package:grass/app/data/models/public_ip_model.dart';
import 'package:grass/app/data/service/dio_client.dart';
import 'package:grass/app/data/utils/url.dart';

class GlobalRepository {
  final dio = DioClient();

  Future<ApiResponse<PublicIpModel>> getIp() async {
    try {
      Response response = await dio.get(Url.deviceIpUrl);

      ApiResponse<PublicIpModel> res = ApiResponse(
          status: response.statusCode,
          res: PublicIpModel.fromJson(response.data));

      return res;
    } catch (e) {
      rethrow;
    }
  }
}
