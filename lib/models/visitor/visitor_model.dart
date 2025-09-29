class Visitor {
	final int id; // ID
	final String name; // name
	final String documentNumber; // documentNumber
	final int? hostId; // host
	final DateTime? enterDate; // enter_date
	final DateTime? exitDate; // exit_date
	final int? ownerId; // Owner_id
	final String hostName; // host_name
	final String? status; // status
	final String? purpose; // visit_purpose
	final String? vehiclePlate; // vehicle_plate
	final String? notes; // notes
	final DateTime? createdAt; // created_at
	final DateTime? updatedAt; // updated_at

	const Visitor({
		required this.id,
		required this.name,
		required this.documentNumber,
		required this.hostId,
		required this.enterDate,
		required this.exitDate,
		required this.ownerId,
		required this.hostName,
		this.status,
		this.purpose,
		this.vehiclePlate,
		this.notes,
		this.createdAt,
		this.updatedAt,
	});

	factory Visitor.fromJson(Map<String, dynamic> json) {
		int toInt(dynamic v, {int defaultValue = 0}) {
			if (v == null) return defaultValue;
			if (v is int) return v;
			return int.tryParse(v.toString()) ?? defaultValue;
		}

		int? toIntOrNull(dynamic v) {
			if (v == null) return null;
			if (v is int) return v;
			return int.tryParse(v.toString());
		}

		DateTime? toDate(dynamic v) {
			if (v == null) return null;
			if (v is DateTime) return v;
			return DateTime.tryParse(v.toString());
		}

		String toStr(dynamic v) => v?.toString() ?? '';

		return Visitor(
			id: toInt(json['ID'] ?? json['id'], defaultValue: 0),
			name: toStr(json['name']),
			documentNumber: toStr(json['documentNumber'] ?? json['document_number']),
			hostId: toIntOrNull(json['host'] ?? json['host_id']),
			enterDate: toDate(json['enter_date'] ?? json['enterDate']),
			exitDate: toDate(json['exit_date'] ?? json['exitDate']),
			ownerId: toIntOrNull(json['Owner_id'] ?? json['owner_id']),
			hostName: toStr(json['host_name'] ?? json['hostName']),
			status: json.containsKey('status') ? toStr(json['status']) : null,
			purpose: json.containsKey('purpose')
				? toStr(json['purpose'] ?? json['visit_purpose'])
				: null,
			vehiclePlate: json.containsKey('vehicle_plate')
				? toStr(json['vehicle_plate'])
				: null,
			notes: json.containsKey('notes') ? toStr(json['notes']) : null,
			createdAt: toDate(json['created_at'] ?? json['createdAt']),
			updatedAt: toDate(json['updated_at'] ?? json['updatedAt']),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'ID': id,
			'name': name,
			'documentNumber': documentNumber,
			'host': hostId,
			'enter_date': enterDate?.toIso8601String(),
			'exit_date': exitDate?.toIso8601String(),
			'Owner_id': ownerId,
			'host_name': hostName,
			'status': status,
			'purpose': purpose,
			'vehicle_plate': vehiclePlate,
			'notes': notes,
			'created_at': createdAt?.toIso8601String(),
			'updated_at': updatedAt?.toIso8601String(),
		};
	}
}
