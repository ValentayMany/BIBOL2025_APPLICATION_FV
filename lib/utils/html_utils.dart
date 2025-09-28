// lib/utils/html_utils.dart
class HtmlUtils {
  static String stripHtmlTags(String htmlString) {
    if (htmlString.isEmpty) return '';
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
