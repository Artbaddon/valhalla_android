class Visitor {
	final int id; // ID
	final String name; // name
	final String documentNumber; // documentNumber
	final int? hostId; // host
	final DateTime? enterDate; // enter_date
	final DateTime? exitDate; // exit_date
	final int? ownerId; // Owner_id
	final String hostName; // host_name

	const Visitor({
		required this.id,
		required this.name,
		required this.documentNumber,
		required this.hostId,
		required this.enterDate,
		required this.exitDate,
		required this.ownerId,
		required this.hostName,
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
		};
	}
}
