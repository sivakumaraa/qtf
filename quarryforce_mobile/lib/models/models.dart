import 'dart:math' as math;
import 'dart:convert';

/// Helper function to safely convert values to double
double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  if (value is num) return value.toDouble();
  return null;
}

/// User/Rep model
class User {
  int? id;
  String username;
  String? name;
  String email;
  String? phone;
  String? photo;
  String? targetStatus;
  int? targetId;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    required this.username,
    this.name,
    required this.email,
    this.phone,
    this.photo,
    this.targetStatus,
    this.targetId,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      username: json['username'] ?? '',
      name: json['name'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['mobile_no'],
      photo: json['photo'],
      targetStatus: json['target_status'],
      targetId: json['target_id'] is String
          ? int.tryParse(json['target_id'])
          : json['target_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'email': email,
      'phone': phone,
      'photo': photo,
      'target_status': targetStatus,
      'target_id': targetId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

/// Customer/Quarry model
class Customer {
  int? id;
  String name;
  String? location;
  double? latitude;
  double? longitude;
  String? contactPerson;
  String? phone;
  String? notes;
  String? materialNeeds; // JSON string: ["RMC"] or ["Aggregates"]
  String? rmcGrade; // e.g., "10-40", "20-40"
  String? aggregateTypes; // JSON string: ["6mm", "12mm", "20mm", "40mm"]
  double? volume;
  String? volumeUnit;
  DateTime? requiredDate;

  Customer({
    this.id,
    required this.name,
    this.location,
    this.latitude,
    this.longitude,
    this.contactPerson,
    this.phone,
    this.notes,
    this.materialNeeds,
    this.rmcGrade,
    this.aggregateTypes,
    this.volume,
    this.volumeUnit,
    this.requiredDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      name: json['name'] ?? '',
      location: json['location'],
      latitude: _toDouble(json['lat'] ?? json['latitude']),
      longitude: _toDouble(json['lng'] ?? json['longitude']),
      contactPerson: json['contact_person'] ?? json['site_incharge_name'],
      phone: json['phone'] ?? json['phone_no'],
      notes: json['notes'],
      materialNeeds: json['material_needs'] is String
          ? json['material_needs']
          : (json['material_needs'] is List
              ? jsonEncode(json['material_needs'])
              : null),
      rmcGrade: json['rmc_grade'],
      aggregateTypes: json['aggregate_types'] is String
          ? json['aggregate_types']
          : (json['aggregate_types'] is List
              ? jsonEncode(json['aggregate_types'])
              : null),
      volume: _toDouble(json['volume']),
      volumeUnit: json['volume_unit'] ?? 'm3',
      requiredDate: json['required_date'] != null
          ? DateTime.parse(json['required_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'contact_person': contactPerson,
      'phone': phone,
      'notes': notes,
      'material_needs': materialNeeds,
      'rmc_grade': rmcGrade,
      'aggregate_types': aggregateTypes,
      'volume': volume,
      'volume_unit': volumeUnit,
      'required_date': requiredDate?.toIso8601String(),
    };
  }

  /// Parse material needs from JSON string to List
  List<String> getMaterialNeedsList() {
    if (materialNeeds == null || materialNeeds!.isEmpty) return [];
    try {
      if (materialNeeds!.startsWith('[')) {
        return List<String>.from(jsonDecode(materialNeeds!) as List);
      }
      return [materialNeeds!];
    } catch (e) {
      return [];
    }
  }

  /// Parse aggregate types from JSON string to List
  List<String> getAggregateTypesList() {
    if (aggregateTypes == null || aggregateTypes!.isEmpty) return [];
    try {
      if (aggregateTypes!.startsWith('[')) {
        return List<String>.from(jsonDecode(aggregateTypes!) as List);
      }
      return [aggregateTypes!];
    } catch (e) {
      return [];
    }
  }

  /// Check if customer needs RMC products
  bool needsRMC() {
    return getMaterialNeedsList().contains('RMC');
  }

  /// Check if customer needs Aggregate products
  bool needsAggregates() {
    return getMaterialNeedsList().contains('Aggregates');
  }

  /// Calculate distance to another location
  double? distanceTo({required double latitude, required double longitude}) {
    if (this.latitude == null || this.longitude == null) return null;

    // Simple distance calculation (would use geolocator in real app)
    const earthRadiusKm = 6371;
    final dLat = _toRad(latitude - this.latitude!);
    final dLon = _toRad(longitude - this.longitude!);
    final a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_toRad(this.latitude!)) *
            math.cos(_toRad(latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRad(double degrees) => degrees * (3.141592653589793 / 180.0);
}

/// Visit model
class Visit {
  int? id;
  int? repId;
  int? customerId;
  String? customerName;
  double? latitude;
  double? longitude;
  String? photoBefore;
  String? photoAfter;
  String? selfiePath;
  DateTime? startTime;
  DateTime? endTime;
  String? notes;
  String? status;
  DateTime? createdAt;

  Visit({
    this.id,
    this.repId,
    this.customerId,
    this.customerName,
    this.latitude,
    this.longitude,
    this.photoBefore,
    this.photoAfter,
    this.selfiePath,
    this.startTime,
    this.endTime,
    this.notes,
    this.status,
    this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      repId: json['rep_id'] is String
          ? int.tryParse(json['rep_id'])
          : json['rep_id'],
      customerId: json['customer_id'] is String
          ? int.tryParse(json['customer_id'])
          : json['customer_id'],
      customerName: json['customer_name'],
      latitude: json['location_lat'],
      longitude: json['location_lon'],
      photoBefore: json['visit_photo_before'],
      photoAfter: json['visit_photo_after'],
      selfiePath: json['selfie_path'],
      startTime: json['visit_start_time'] != null
          ? DateTime.parse(json['visit_start_time'] as String)
          : null,
      endTime: json['visit_end_time'] != null
          ? DateTime.parse(json['visit_end_time'] as String)
          : null,
      notes: json['notes'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rep_id': repId,
      'customer_id': customerId,
      'customer_name': customerName,
      'location_lat': latitude,
      'location_lon': longitude,
      'visit_photo_before': photoBefore,
      'visit_photo_after': photoAfter,
      'selfie_path': selfiePath,
      'visit_start_time': startTime?.toIso8601String(),
      'visit_end_time': endTime?.toIso8601String(),
      'notes': notes,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get duration of visit in minutes
  int? getDurationMinutes() {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!).inMinutes;
  }
}

/// Fuel log model
class FuelLog {
  int? id;
  int? repId;
  double? fuelLiters;
  double? fuelCost;
  String? fuelType; // 'petrol' or 'diesel'
  String? receiptPhotoPath;
  double? latitude;
  double? longitude;
  String? notes;
  String? status;
  DateTime? createdAt;

  FuelLog({
    this.id,
    this.repId,
    this.fuelLiters,
    this.fuelCost,
    this.fuelType,
    this.receiptPhotoPath,
    this.latitude,
    this.longitude,
    this.notes,
    this.status,
    this.createdAt,
  });

  factory FuelLog.fromJson(Map<String, dynamic> json) {
    return FuelLog(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      repId: json['rep_id'] is String
          ? int.tryParse(json['rep_id'])
          : json['rep_id'],
      fuelLiters: json['fuel_liters'],
      fuelCost: json['fuel_cost'],
      fuelType: json['fuel_type'],
      receiptPhotoPath: json['receipt_photo_path'],
      latitude: json['location_lat'],
      longitude: json['location_lon'],
      notes: json['notes'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rep_id': repId,
      'fuel_liters': fuelLiters,
      'fuel_cost': fuelCost,
      'fuel_type': fuelType,
      'receipt_photo_path': receiptPhotoPath,
      'location_lat': latitude,
      'location_lon': longitude,
      'notes': notes,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Get cost per liter
  double? getCostPerLiter() {
    if (fuelLiters == null || fuelCost == null || fuelLiters == 0) return null;
    return fuelCost! / fuelLiters!;
  }
}

/// Sales target model
class SalesTarget {
  int? id;
  int? repId;
  int? monthlySalesTargetM3;
  double? incentiveRatePerM3;
  double? maxIncentivePerM3;
  double? penaltyRatePerM3;
  String? status;
  DateTime? createdAt;

  SalesTarget({
    this.id,
    this.repId,
    this.monthlySalesTargetM3,
    this.incentiveRatePerM3,
    this.maxIncentivePerM3,
    this.penaltyRatePerM3,
    this.status,
    this.createdAt,
  });

  factory SalesTarget.fromJson(Map<String, dynamic> json) {
    return SalesTarget(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      repId: json['rep_id'] is String
          ? int.tryParse(json['rep_id'])
          : json['rep_id'],
      monthlySalesTargetM3: _toDouble(json['monthly_sales_target_m3'])?.round(),
      incentiveRatePerM3: _toDouble(json['incentive_rate_per_m3']),
      maxIncentivePerM3: _toDouble(json['incentive_rate_max_per_m3']),
      penaltyRatePerM3: _toDouble(json['penalty_rate_per_m3']),
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rep_id': repId,
      'monthly_sales_target_m3': monthlySalesTargetM3,
      'incentive_rate_per_m3': incentiveRatePerM3,
      'incentive_rate_max_per_m3': maxIncentivePerM3,
      'penalty_rate_per_m3': penaltyRatePerM3,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

/// Compensation/Progress model
class Compensation {
  int? id;
  int? repId;
  String? month;
  int? salesVolumeM3;
  double? bonusEarned;
  double? penaltyAmount;
  double? netCompensation;
  String? status;
  DateTime? createdAt;

  Compensation({
    this.id,
    this.repId,
    this.month,
    this.salesVolumeM3,
    this.bonusEarned,
    this.penaltyAmount,
    this.netCompensation,
    this.status,
    this.createdAt,
  });

  factory Compensation.fromJson(Map<String, dynamic> json) {
    return Compensation(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      repId: json['rep_id'] is String
          ? int.tryParse(json['rep_id'])
          : json['rep_id'],
      month: json['month']?.toString(),
      salesVolumeM3: _toDouble(json['sales_volume_m3'])?.round(),
      bonusEarned: _toDouble(json['bonus_earned']),
      penaltyAmount: _toDouble(json['penalty_amount']),
      netCompensation: _toDouble(json['net_compensation']),
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rep_id': repId,
      'month': month,
      'sales_volume_m3': salesVolumeM3,
      'bonus_earned': bonusEarned,
      'penalty_amount': penaltyAmount,
      'net_compensation': netCompensation,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Check if target was achieved
  bool targetAchieved(int? target) {
    if (target == null || salesVolumeM3 == null) return false;
    return salesVolumeM3! >= target;
  }

  /// Get performance percentage
  double getPercentage(int? target) {
    if (target == null || target == 0 || salesVolumeM3 == null) return 0.0;
    return (salesVolumeM3! / target) * 100;
  }
}

/// Order Item model - Line items in an order
class OrderItem {
  int? id;
  int? orderId;
  String productName;
  String? materialType;
  String? volumeUnit;
  double quantity;
  double unitPrice;
  double? totalPrice;
  double? boomPumpAmount;
  DateTime? requiredDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  OrderItem({
    this.id,
    this.orderId,
    required this.productName,
    this.materialType,
    this.volumeUnit,
    required this.quantity,
    required this.unitPrice,
    this.totalPrice,
    this.boomPumpAmount,
    this.requiredDate,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      orderId: json['order_id'] is String
          ? int.tryParse(json['order_id'])
          : json['order_id'],
      productName: json['product_name'] ?? '',
      materialType: json['material_type'],
      volumeUnit: json['volume_unit'],
      quantity: _toDouble(json['quantity']) ?? 0.0,
      unitPrice: _toDouble(json['unit_price']) ?? 0.0,
      totalPrice: _toDouble(json['total_price']),
      boomPumpAmount: _toDouble(json['boom_pump_amount']),
      requiredDate: json['required_date'] != null
          ? DateTime.tryParse(json['required_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_name': productName,
      'material_type': materialType,
      'volume_unit': volumeUnit,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice ?? (quantity * unitPrice),
      'boom_pump_amount': boomPumpAmount,
      'required_date': requiredDate?.toIso8601String().split('T')[0],
    };
  }

  double calculateTotal() {
    return quantity * unitPrice;
  }
}

/// Order model
class Order {
  int? id;
  int? repId;
  String? repName;
  int? customerId;
  String? customerName;
  double? orderAmount;
  DateTime? orderDate;
  String? productDetails;
  String status;
  List<OrderItem> items;
  DateTime? createdAt;
  DateTime? updatedAt;

  Order({
    this.id,
    this.repId,
    this.repName,
    this.customerId,
    this.customerName,
    this.orderAmount,
    this.orderDate,
    this.productDetails,
    this.status = 'pending',
    List<OrderItem>? items,
    this.createdAt,
    this.updatedAt,
  }) : items = items ?? [];

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      repId: json['rep_id'] is String
          ? int.tryParse(json['rep_id'])
          : json['rep_id'],
      repName: json['rep_name'],
      customerId: json['customer_id'] is String
          ? int.tryParse(json['customer_id'])
          : json['customer_id'],
      customerName: json['customer_name'],
      orderAmount: _toDouble(json['order_amount']),
      orderDate: json['order_date'] != null
          ? DateTime.parse(json['order_date'] as String)
          : null,
      productDetails: json['product_details'],
      status: json['status'] ?? 'pending',
      items: json['items'] is List
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rep_id': repId,
      'rep_name': repName,
      'customer_id': customerId,
      'customer_name': customerName,
      'order_amount': orderAmount ?? calculateTotalAmount(),
      'order_date':
          orderDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'product_details': productDetails,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  double calculateTotalAmount() {
    return items.fold(0.0, (sum, item) => sum + item.calculateTotal());
  }

  void addItem(OrderItem item) {
    items.add(item);
  }

  void removeItem(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
    }
  }

  int getItemCount() => items.length;

  bool isValid() => repId != null && customerId != null && items.isNotEmpty;
}
