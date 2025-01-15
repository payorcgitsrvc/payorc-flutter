import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pay_orc/src/helper/api_paths.dart';
import 'package:flutter_pay_orc/src/network/models/pay_orc_error.dart';
import 'package:flutter_pay_orc/src/network/models/pay_orc_keys_request.dart';
import 'package:flutter_pay_orc/src/network/models/pay_orc_keys_valid.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'models/pay_orc_payment_request.dart';
import 'models/pay_orc_payment_response.dart';
import 'models/pay_orc_payment_transaction_response.dart';

class FlutterPayOrcClient {
  final Dio _dio;

  /// Dio client initialisation
  FlutterPayOrcClient(
      {required String merchantKey,
      required String merchantSecret,
      required String paymentBaseUrl})
      : _dio = Dio(BaseOptions(
            baseUrl: paymentBaseUrl,
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 60),
            headers: {
              'merchant-key': merchantKey,
              'merchant-secret': merchantSecret,
              'Content-Type': 'application/json',
            })) {
    // Add logging interceptor
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: kDebugMode,
      requestBody: kDebugMode,
      responseBody: kDebugMode,
      responseHeader: kDebugMode,
      error: kDebugMode,
      compact: kDebugMode,
    ));
  }

  /// Api to validate merchant keys
  Future<PayOrcKeysValid> validateMerchantKeys(
      PayOrcKeysRequest request) async {
    try {
      Map requestData = request.toJson();
      final response = await _dio.post(
        ApiPaths.URL_CHECK_KEYS,
        data: jsonEncode(requestData),
      );
      if (response.statusCode == 200) {
        return PayOrcKeysValid.fromJson(response.data);
      } else {
        throw HttpException('Failed to create order request');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        final payOrcError = PayOrcError.fromJson(e.response!.data);
        throw HttpException('${payOrcError.message}');
      } else {
        throw HttpException('${e.message}');
      }
    }
  }

  /// Api to create payment
  Future<PayOrcPaymentResponse> createPayment(
      PayOrcPaymentRequest request) async {
    try {
      Map requestData = request.toJson();
      final response = await _dio.post(
        ApiPaths.URL_CREATE_PAYMENT,
        data: jsonEncode(requestData),
      );
      if (response.statusCode == 200) {
        return PayOrcPaymentResponse.fromJson(response.data);
      } else {
        throw HttpException('Failed to create order request');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        final payOrcError = PayOrcError.fromJson(e.response!.data);
        throw HttpException('${payOrcError.message}');
      } else {
        throw HttpException('${e.message}');
      }
    }
  }

  /// Api to fetch payment transaction
  Future<PayOrcPaymentTransactionResponse> fetchPaymentTransaction(
      String orderId) async {
    try {
      final response = await _dio.get(
        ApiPaths.URL_PAYMENT_TRANSACTION,
        queryParameters: {'p_order_id': orderId},
      );
      if (response.statusCode == 200) {
        return PayOrcPaymentTransactionResponse.fromJson(response.data);
      } else {
        throw HttpException('Failed to fetch transaction');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        final payOrcError = PayOrcError.fromJson(e.response!.data);
        throw HttpException('${payOrcError.message}');
      } else {
        throw HttpException('${e.message}');
      }
    }
  }
}
