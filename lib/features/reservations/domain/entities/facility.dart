class Facility {
  final int id;
  final String name;
  final String type; // 'BBQ', 'Piscina', 'Gimnasio', etc.
  final String description;
  final int capacity;
  final bool isActive;
  final List<String> amenities;
  final String? imageUrl;
  final double? hourlyRate;
  final Map<int, List<TimeSlot>> availableSlots; // weekday -> slots

  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.capacity,
    required this.isActive,
    required this.amenities,
    this.imageUrl,
    this.hourlyRate,
    required this.availableSlots,
  });

  factory Facility.fromMap(Map<String, dynamic> map) {
    return Facility(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      capacity: map['capacity'] ?? 1,
      isActive: map['isActive'] ?? true,
      amenities: List<String>.from(map['amenities'] ?? []),
      imageUrl: map['imageUrl'],
      hourlyRate: map['hourlyRate']?.toDouble(),
      availableSlots: _parseAvailableSlots(map['availableSlots'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'capacity': capacity,
      'isActive': isActive,
      'amenities': amenities,
      'imageUrl': imageUrl,
      'hourlyRate': hourlyRate,
      'availableSlots': _availableSlotsToMap(),
    };
  }

  static Map<int, List<TimeSlot>> _parseAvailableSlots(Map<String, dynamic> slotsMap) {
    final result = <int, List<TimeSlot>>{};
    
    for (final entry in slotsMap.entries) {
      final weekday = int.tryParse(entry.key);
      if (weekday != null && entry.value is List) {
        result[weekday] = (entry.value as List)
            .map((slot) => TimeSlot.fromMap(Map<String, dynamic>.from(slot)))
            .toList();
      }
    }
    
    return result;
  }

  Map<String, dynamic> _availableSlotsToMap() {
    final result = <String, dynamic>{};
    
    for (final entry in availableSlots.entries) {
      result[entry.key.toString()] = entry.value.map((slot) => slot.toMap()).toList();
    }
    
    return result;
  }

  List<TimeSlot> getSlotsForWeekday(int weekday) {
    return availableSlots[weekday] ?? [];
  }

  bool isAvailableOnWeekday(int weekday) {
    return availableSlots.containsKey(weekday) && 
           availableSlots[weekday]!.isNotEmpty;
  }
}

class TimeSlot {
  final String startTime; // e.g., "09:00"
  final String endTime;   // e.g., "18:00"
  final bool isAvailable;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      startTime: map['startTime'] ?? '09:00',
      endTime: map['endTime'] ?? '18:00',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }

  // Parse time string to DateTime for today
  DateTime get startDateTime {
    final parts = startTime.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 
                   int.parse(parts[0]), int.parse(parts[1]));
  }

  DateTime get endDateTime {
    final parts = endTime.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 
                   int.parse(parts[0]), int.parse(parts[1]));
  }

  String get displayTime => '$startTime - $endTime';
}