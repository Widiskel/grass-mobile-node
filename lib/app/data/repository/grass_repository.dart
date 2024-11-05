import 'package:dio/dio.dart';
import 'package:grass/app/data/models/active_device_list_model.dart';
import 'package:grass/app/data/models/api_response.dart';
import 'package:grass/app/data/models/stage_list_model.dart';
import 'package:grass/app/data/service/dio_client.dart';
import 'package:grass/app/data/utils/url.dart';

class GrassRepository {
  final dio = DioClient();

  Future<ApiResponse<StageListModel>> getEpochStage() async {
    try {
      Response response = await dio.get(Url.stageUrl);

      ApiResponse<StageListModel> res = ApiResponse(
          status: response.statusCode,
          res: StageListModel.fromJson(response.data));

      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<ActiveDeviceListModel>> getActiveDevices() async {
    try {
      Response response = await dio.get(Url.activeDeviceUrl);

      ApiResponse<ActiveDeviceListModel> res = ApiResponse(
          status: response.statusCode,
          res: ActiveDeviceListModel.fromJson(response.data));

      return res;
    } catch (e) {
      rethrow;
    }
  }
}
