class AddressEntity {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String? state;
  final String zipCode;
  final String country;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.state,
    required this.zipCode,
    required this.country,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  AddressEntity copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phone,
    String? street,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return '$fullName, $street, $city, ${state ?? ''}, $zipCode, $country';
  }

  String get shortAddress {
    return '$street, $city${state != null ? ', $state' : ''}';
  }
}