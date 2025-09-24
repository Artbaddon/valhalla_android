import '../../domain/entities/facility.dart';

class FacilityModel {
  final int id;
  final String name;
  final String type;
  final String description;
  final int capacity;
  final bool isActive;
  final List<String> amenities;
  final String? imageUrl;
  final double? hourlyRate;
  final Map<String, dynamic> availableSlots;

  const FacilityModel({
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

  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      capacity: json['capacity'] ?? 1,
      isActive: json['isActive'] ?? true,
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities']) 
          : [],
      imageUrl: json['imageUrl'],
      hourlyRate: json['hourlyRate']?.toDouble(),
      availableSlots: json['availableSlots'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
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
      'availableSlots': availableSlots,
    };
  }
}

extension FacilityModelExtensions on FacilityModel {
  Facility toEntity() {
    // Convert availableSlots from Map<String, dynamic> to Map<int, List<TimeSlot>>
    final Map<int, List<TimeSlot>> slots = {};
    
    availableSlots.forEach((key, value) {
      final dayOfWeek = int.tryParse(key) ?? 1;
      final List<TimeSlot> timeSlots = [];
      
      if (value is List) {
        for (var slot in value) {
          if (slot is Map<String, dynamic>) {
            timeSlots.add(TimeSlot(
              startTime: slot['startTime'] ?? '09:00',
              endTime: slot['endTime'] ?? '18:00',
              isAvailable: slot['isAvailable'] ?? true,
            ));
          }
        }
      }
      
      slots[dayOfWeek] = timeSlots;
    });

    return Facility(
      id: id,
      name: name,
      type: type,
      description: description,
      capacity: capacity,
      isActive: isActive,
      amenities: amenities,
      imageUrl: imageUrl,
      hourlyRate: hourlyRate,
      availableSlots: slots,
    );
  }
}

extension FacilityEntityExtensions on Facility {
  FacilityModel toModel() {
    // Convert availableSlots from Map<int, List<TimeSlot>> to Map<String, dynamic>
    final Map<String, dynamic> slots = {};
    
    availableSlots.forEach((dayOfWeek, timeSlots) {
      slots[dayOfWeek.toString()] = timeSlots.map((slot) => {
        'startTime': slot.startTime,
        'endTime': slot.endTime,
      }).toList();
    });

    return FacilityModel(
      id: id,
      name: name,
      type: type,
      description: description,
      capacity: capacity,
      isActive: isActive,
      amenities: amenities,
      imageUrl: imageUrl,
      hourlyRate: hourlyRate,
      availableSlots: slots,
    );
  }
}