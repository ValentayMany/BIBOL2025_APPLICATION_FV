class WebsiteInfoModel {
  final String siteUrl;
  final String siteTitle;
  final String siteDesc;
  final String siteKeywords;
  final String siteWebmails;

  WebsiteInfoModel({
    required this.siteUrl,
    required this.siteTitle,
    required this.siteDesc,
    required this.siteKeywords,
    required this.siteWebmails,
  });

  factory WebsiteInfoModel.fromJson(Map<String, dynamic> json) {
    return WebsiteInfoModel(
      siteUrl: json['site_url'] ?? '',
      siteTitle: json['site_title'] ?? '',
      siteDesc: json['site_desc'] ?? '',
      siteKeywords: json['site_keywords'] ?? '',
      siteWebmails: json['site_webmails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'site_url': siteUrl,
      'site_title': siteTitle,
      'site_desc': siteDesc,
      'site_keywords': siteKeywords,
      'site_webmails': siteWebmails,
    };
  }
}
