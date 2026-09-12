import 'dart:io';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../core/error/failure.dart';
import '../models/article.dart';

class NetworkService {
  final Dio _dio;

  NetworkService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.gnewsBaseUrl,
                connectTimeout: Duration(seconds: AppConstants.networkTimeoutSeconds),
                receiveTimeout: Duration(seconds: AppConstants.networkTimeoutSeconds),
                sendTimeout: Duration(seconds: AppConstants.networkTimeoutSeconds),
              ),
            );

  Failure _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const TimeoutFailure();
    }
    if (error.type == DioExceptionType.connectionError || error.error is SocketException) {
      return const NoInternetFailure();
    }
    if (error.response != null) {
      final statusCode = error.response?.statusCode;
      final message = error.response?.data?['errors']?[0] ?? 'Server error ($statusCode)';
      return InvalidDataFailure(message.toString());
    }
    return UnknownFailure(error.message ?? 'Network error');
  }

  Future<List<Article>> fetchTopHeadlines({
    String category = 'general',
    int page = 1,
  }) async {
    try {
      final apiKey = AppConstants.gnewsApiKey;
      final response = await _dio.get(
        '/top-headlines',
        queryParameters: {
          'category': category,
          'lang': 'en',
          'max': AppConstants.pageSize,
          'page': page,
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final rawArticles = data['articles'] as List<dynamic>? ?? [];
        return rawArticles.map((json) {
          final map = json as Map<String, dynamic>;
          map['category'] = category;
          return Article.fromJson(map);
        }).toList();
      } else {
        throw const InvalidDataFailure('Failed to fetch headlines');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }

  Future<List<Article>> searchArticles({
    required String query,
    int page = 1,
  }) async {
    if (query.trim().isEmpty) return [];
    try {
      final apiKey = AppConstants.gnewsApiKey;
      final response = await _dio.get(
        '/search',
        queryParameters: {
          'q': query.trim(),
          'lang': 'en',
          'max': AppConstants.pageSize,
          'page': page,
          'apikey': apiKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final rawArticles = data['articles'] as List<dynamic>? ?? [];
        return rawArticles.map((json) {
          final map = json as Map<String, dynamic>;
          return Article.fromJson(map);
        }).toList();
      } else {
        throw const InvalidDataFailure('Failed to search articles');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure(e.toString());
    }
  }
}
