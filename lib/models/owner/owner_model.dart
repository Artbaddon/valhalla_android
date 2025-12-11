class Owner {
  final int ownerId;
  final int userFkId;
  final int ownerIsTenant;
  final String? ownerBirthDate;
  final String? ownerCreatedAt;
  final String? ownerUpdatedAt;

  // Campos de Users
  final String? userEmail;

  // Campos de Profile
  final String? ownerName; // Mantenemos ownerName pero mapeamos correctamente
  final String? profileDocumentType;
  final String? profileDocumentNumber;
  final String? profileTelephoneNumber;

  // Campo de status (viene directamente como "status" en el JSON)
  final String? status;

  Owner({
    required this.ownerId,
    required this.userFkId,
    required this.ownerIsTenant,
    this.ownerBirthDate,
    this.ownerCreatedAt,
    this.ownerUpdatedAt,
    this.userEmail,
    this.ownerName,
    this.profileDocumentType,
    this.profileDocumentNumber,
    this.profileTelephoneNumber,
    this.status,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      ownerId: (json["Owner_id"] as int?) ?? 0,
      userFkId: (json["User_FK_ID"] as int?) ?? 0,
      ownerIsTenant: (json["Owner_is_tenant"] as int?) ?? 0,
      ownerBirthDate: json["Owner_birth_date"] as String?,
      ownerCreatedAt: json["Owner_createdAt"] as String?,
      ownerUpdatedAt: json["Owner_updatedAt"] as String?,
      userEmail: json["Users_email"] as String?,
      // ✅ CORREGIDO: ownerName ahora se mapea a Profile_fullName
      ownerName: json["Profile_fullName"] as String?,
      profileDocumentType: json["Profile_document_type"] as String?,
      profileDocumentNumber: json["Profile_document_number"] as String?,
      profileTelephoneNumber: json["Profile_telephone_number"] as String?,
      status: json["status"] as String?,
    );
  }

  // ✅ PROPIEDADES CALCULADAS (sin cambios)
  String get fullName => ownerName ?? 'Propietario $ownerId';
  String get residentType => ownerIsTenant == 1 ? 'Inquilino' : 'Propietario';
  String get safeEmail => userEmail ?? 'No especificado';
  String get safePhone => profileTelephoneNumber ?? 'No especificado';
  String get safeDocumentNumber => profileDocumentNumber ?? 'No especificado';
  String get safeDocumentType => profileDocumentType ?? 'No especificado';
  String get safeStatus => status ?? 'No especificado';

  // ... resto de métodos igual que antes

  Map<String, dynamic> toJson() {
    return {
      'Owner_id': ownerId,
      'User_FK_ID': userFkId,
      'Owner_is_tenant': ownerIsTenant,
      'Owner_birth_date': ownerBirthDate,
      'Owner_createdAt': ownerCreatedAt,
      'Owner_updatedAt': ownerUpdatedAt,
      'Users_email': userEmail,
      'Profile_fullName': ownerName, // ✅ Mapeo inverso correcto
      'Profile_document_type': profileDocumentType,
      'Profile_document_number': profileDocumentNumber,
      'Profile_telephone_number': profileTelephoneNumber,
      'status': status,
    };
  }
}
