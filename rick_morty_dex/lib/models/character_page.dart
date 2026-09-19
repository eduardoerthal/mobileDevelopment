import 'character.dart';

/// Pagination metadata returned by rickandmortyapi.com list endpoints
/// under the `info` key, e.g.:
/// ```json
/// {
///   "count": 826,
///   "pages": 42,
///   "next": "https://rickandmortyapi.com/api/character?page=2",
///   "prev": null
/// }
/// ```
class PageInfo {
  final int count;
  final int pages;
  final String? next;
  final String? prev;

  const PageInfo({
    required this.count,
    required this.pages,
    this.next,
    this.prev,
  });

  /// Whether there is another page after the current one.
  bool get hasNextPage => next != null;

  /// The page number to request next, parsed from [next]'s `page`
  /// query parameter, or `null` when there is no next page.
  int? get nextPage {
    final nextUrl = next;
    if (nextUrl == null) return null;
    final pageParam = Uri.parse(nextUrl).queryParameters['page'];
    return pageParam != null ? int.tryParse(pageParam) : null;
  }

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      count: json['count'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      next: json['next'] as String?,
      prev: json['prev'] as String?,
    );
  }
}

/// A page of characters as returned by the `/character` list (and
/// name-search) endpoint: the `results` array plus its `info`.
class CharacterPage {
  final List<Character> results;
  final PageInfo info;

  const CharacterPage({
    required this.results,
    required this.info,
  });

  factory CharacterPage.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? const [];
    return CharacterPage(
      results: rawResults
          .map((item) => Character.fromJson(item as Map<String, dynamic>))
          .toList(),
      info: PageInfo.fromJson(
        json['info'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}
