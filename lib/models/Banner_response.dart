import 'banner_models.dart' show BannerModel;

/// Response model for banner list API
class BannerListResponse {
  final String msg;
  final int type;
  final int bannersCount;
  final List<BannerModel> banners;

  const BannerListResponse({
    required this.msg,
    required this.type,
    required this.bannersCount,
    required this.banners,
  });

  factory BannerListResponse.fromJson(Map<String, dynamic> json) {
    return BannerListResponse(
      msg: json['msg'] ?? '',
      type: json['type'] ?? 0,
      bannersCount: json['banners_count'] ?? 0,
      banners:
          (json['banners'] as List<dynamic>?)
              ?.map((bannerJson) => BannerModel.fromJson(bannerJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg': msg,
      'type': type,
      'banners_count': bannersCount,
      'banners': banners.map((banner) => banner.toJson()).toList(),
    };
  }

  // Helper getters
  bool get hasData => banners.isNotEmpty;
  bool get isSuccess => type == 1;
  int get actualCount => banners.length;
  List<BannerModel> get activeBanners =>
      banners.where((banner) => banner.isActive).toList();

  @override
  String toString() {
    return 'BannerListResponse(msg: $msg, type: $type, bannersCount: $bannersCount, actualBanners: ${banners.length})';
  }
}

/// Response model for single banner API
class BannerDetailResponse {
  final String msg;
  final int type;
  final BannerModel? banner;

  const BannerDetailResponse({
    required this.msg,
    required this.type,
    this.banner,
  });

  factory BannerDetailResponse.fromJson(Map<String, dynamic> json) {
    BannerModel? bannerData;

    // Handle different response formats
    if (json['data'] != null) {
      bannerData = BannerModel.fromJson(json['data']);
    } else if (json['banner'] != null) {
      bannerData = BannerModel.fromJson(json['banner']);
    } else if (json.containsKey('id')) {
      // Direct banner object
      bannerData = BannerModel.fromJson(json);
    }

    return BannerDetailResponse(
      msg: json['msg'] ?? '',
      type: json['type'] ?? 0,
      banner: bannerData,
    );
  }

  Map<String, dynamic> toJson() {
    return {'msg': msg, 'type': type, 'data': banner?.toJson()};
  }

  // Helper getters
  bool get hasData => banner != null;
  bool get isSuccess => type == 1 && banner != null;
  bool get notFound => banner == null;

  @override
  String toString() {
    return 'BannerDetailResponse(msg: $msg, type: $type, hasBanner: ${banner != null})';
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(
      success: true,
      message: message ?? 'Success',
      data: data,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, hasData: ${data != null})';
  }
}

/// Error response model
class ErrorResponse {
  final String error;
  final String? details;
  final int? code;

  const ErrorResponse({required this.error, this.details, this.code});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      error: json['error'] ?? json['message'] ?? 'Unknown error',
      details: json['details'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'error': error, 'details': details, 'code': code};
  }

  @override
  String toString() {
    return 'ErrorResponse(error: $error, code: $code)';
  }
}
