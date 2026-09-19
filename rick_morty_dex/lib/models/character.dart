/// Reference to a location as embedded in a [Character] response
/// (the `origin` and `location` fields), e.g.:
/// ```json
/// {
///   "name": "Earth (C-137)",
///   "url": "https://rickandmortyapi.com/api/location/1"
/// }
/// ```
/// The API returns `name: "unknown"` and `url: ""` when the location
/// is not known, so both fields are always present but may be empty.
class LocationReference {
  final String name;
  final String url;

  const LocationReference({
    required this.name,
    required this.url,
  });

  factory LocationReference.fromJson(Map<String, dynamic> json) {
    return LocationReference(
      name: json['name'] as String? ?? 'unknown',
      url: json['url'] as String? ?? '',
    );
  }

  /// Inverse of [LocationReference.fromJson] — used to persist favorited/
  /// viewed characters locally (see [Character.toJson]).
  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
  };
}

/// A character as returned by the rickandmortyapi.com `/character`
/// endpoint (single item or an entry of the paginated `results` list).
class Character {
  final int id;
  final String name;

  /// One of "Alive", "Dead" or "unknown".
  final String status;
  final String species;

  /// Subspecies/variant, e.g. "Parasite". Often an empty string.
  final String type;

  /// One of "Female", "Male", "Genderless" or "unknown".
  final String gender;
  final LocationReference origin;
  final LocationReference location;

  /// URL of the character's avatar image.
  final String image;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.origin,
    required this.location,
    required this.image,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'unknown',
      species: json['species'] as String? ?? '',
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String? ?? 'unknown',
      origin: LocationReference.fromJson(
        json['origin'] as Map<String, dynamic>? ?? const {},
      ),
      location: LocationReference.fromJson(
        json['location'] as Map<String, dynamic>? ?? const {},
      ),
      image: json['image'] as String? ?? '',
    );
  }

  /// Inverse of [Character.fromJson] — used to persist this character
  /// locally (favorites/consumed lists) as JSON via shared_preferences.
  /// Only the fields this app models are round-tripped; `episode`, `url`
  /// and `created` from the API response are not kept.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'species': species,
    'type': type,
    'gender': gender,
    'origin': origin.toJson(),
    'location': location.toJson(),
    'image': image,
  };
}
