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
  final String? ownerName;
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

  // =======================================================
  // 🚀 FROMJSON ACTUALIZADO según la estructura del JSON
  // =======================================================
  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      // Campos INT REQUERIDOS
      ownerId: (json["Owner_id"] as int?) ?? 0,
      userFkId: (json["User_FK_ID"] as int?) ?? 0,
      ownerIsTenant: (json["Owner_is_tenant"] as int?) ?? 0,

      // Campos de fecha
      ownerBirthDate: json["Owner_birth_date"] as String?,
      ownerCreatedAt: json["Owner_createdAt"] as String?,
      ownerUpdatedAt: json["Owner_updatedAt"] as String?,

      // Campos de Users
      userEmail: json["Users_email"] as String?,

      // Campos de Profile
      ownerName: json["owner_name"] as String?,
      profileDocumentType: json["Profile_document_type"] as String?,
      profileDocumentNumber: json["Profile_document_number"] as String?,
      profileTelephoneNumber: json["Profile_telephone_number"] as String?,

      // Campo de status
      status: json["status"] as String?,
    );
  }

  // ✅ PROPIEDADES CALCULADAS
  String get fullName => ownerName ?? 'Propietario $ownerId';
  String get residentType => ownerIsTenant == 1 ? 'Inquilino' : 'Propietario';
  String get safeEmail => userEmail ?? 'No especificado';
  String get safePhone => profileTelephoneNumber ?? 'No especificado';
  String get safeDocumentNumber => profileDocumentNumber ?? 'No especificado';
  String get safeDocumentType => profileDocumentType ?? 'No especificado';
  String get safeStatus => status ?? 'No especificado';

  // Método para formatear la fecha de nacimiento (opcional)
  String? get formattedBirthDate {
    if (ownerBirthDate == null) return null;
    try {
      final date = DateTime.parse(ownerBirthDate!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return ownerBirthDate;
    }
  }

  // Método para obtener la edad (opcional)
  int? get age {
    if (ownerBirthDate == null) return null;
    try {
      final birthDate = DateTime.parse(ownerBirthDate!);
      final now = DateTime.now();
      int age = now.year - birthDate.year;
      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'Owner{id: $ownerId, name: $fullName, email: $safeEmail, type: $residentType, status: $safeStatus}';
  }

  // Método para convertir a Map (útil para updates)
  Map<String, dynamic> toJson() {
    return {
      'Owner_id': ownerId,
      'User_FK_ID': userFkId,
      'Owner_is_tenant': ownerIsTenant,
      'Owner_birth_date': ownerBirthDate,
      'Owner_createdAt': ownerCreatedAt,
      'Owner_updatedAt': ownerUpdatedAt,
      'Users_email': userEmail,
      'owner_name': ownerName,
      'Profile_document_type': profileDocumentType,
      'Profile_document_number': profileDocumentNumber,
      'Profile_telephone_number': profileTelephoneNumber,
      'status': status,
    };
  }
}