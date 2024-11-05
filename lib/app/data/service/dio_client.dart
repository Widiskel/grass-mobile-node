import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:grass/app/data/utils/prefs_constant.dart';
import 'package:grass/app/data/utils/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/snackbar_widget.dart';

class DioClient {
  late Dio _dio;

  DioClient() {
    _initApiClient();
  }

  void _initApiClient() {
    BaseOptions options = BaseOptions(
      baseUrl: Url.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      responseType: ResponseType.json,
      validateStatus: (status) {
        return status != null && status < 500;
      },
    );
    _dio = Dio(options);
  }

  Future<Map<String, dynamic>> generateHeader() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(PrefsConstant.token);
    Map<String, dynamic> header = {
      HttpHeaders.acceptHeader: 'Accept: application/json, text/plain, */*',
    };
    if (token != null) {
      header[HttpHeaders.authorizationHeader] = token.replaceAll('"', "");
    }

    log('DIO API Request Header ${header.toString()}');
    return header;
  }

  Future<dynamic> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      log('DIO API GET Request');
      log('DIO API URL: $url');
      log('DIO API Query Parameters: ${queryParameters.toString()}');

      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: await generateHeader()),
      );

      log('DIO API Response Status: ${response.statusCode}');
      log('DIO API Response Data: ${response.data.toString()}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      log('Error in GET: ${e.toString()}');
      rethrow;
    }
  }

  Future<dynamic> post(String url, {Map<String, dynamic>? body}) async {
    try {
      log('DIO API POST Request');
      log('DIO API URL: $url');
      log('DIO API Body: ${body.toString()}');

      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: await generateHeader()),
      );

      log('DIO API Response Status: ${response.statusCode}');
      log('DIO API Response Data: ${response.data.toString()}');
      return response;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      log('Error in POST: ${e.toString()}');
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    log('DIO API Exception: ${e.toString()} | Type: ${e.type}');
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError) {
      ErrorSnack.show(
          message:
              'Failed to connect to server, check your internet connection');
    } else if (e.response?.statusCode == 404) {
      ErrorSnack.show(message: 'Resource not found');
    } else if (e.response?.statusCode == 500) {
      ErrorSnack.show(message: 'Server error, please try again later');
    } else {
      ErrorSnack.show(message: 'An unexpected error occurred');
    }
  }
}
