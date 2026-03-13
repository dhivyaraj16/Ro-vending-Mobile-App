// ============ USER MODEL ============
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final double walletBalance;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.walletBalance = 0.0,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'walletBalance': walletBalance,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    double? walletBalance,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt,
    );
  }
}

// ============ RO MACHINE MODEL ============
class ROmachine {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isOnline;
  final bool isAvailable;
  final double pricePerLitre;
  final double totalWaterDispensed;
  final int totalUsers;
  final String machineCode;
  final DateTime lastMaintenance;
  final String? imageUrl;

  ROmachine({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isOnline,
    required this.isAvailable,
    required this.pricePerLitre,
    required this.totalWaterDispensed,
    required this.totalUsers,
    required this.machineCode,
    required this.lastMaintenance,
    this.imageUrl,
  });

  factory ROmachine.fromMap(Map<String, dynamic> map) {
    return ROmachine(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      isOnline: map['isOnline'] ?? false,
      isAvailable: map['isAvailable'] ?? false,
      pricePerLitre: (map['pricePerLitre'] ?? 1.0).toDouble(),
      totalWaterDispensed: (map['totalWaterDispensed'] ?? 0.0).toDouble(),
      totalUsers: map['totalUsers'] ?? 0,
      machineCode: map['machineCode'] ?? '',
      lastMaintenance: map['lastMaintenance']?.toDate() ?? DateTime.now(),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isOnline': isOnline,
      'isAvailable': isAvailable,
      'pricePerLitre': pricePerLitre,
      'totalWaterDispensed': totalWaterDispensed,
      'totalUsers': totalUsers,
      'machineCode': machineCode,
      'lastMaintenance': lastMaintenance,
      'imageUrl': imageUrl,
    };
  }
}

// ============ TRANSACTION MODEL ============
enum TransactionType { waterPurchase, walletTopup, refund }
enum TransactionStatus { pending, success, failed }

class TransactionModel {
  final String id;
  final String userId;
  final String? machineId;
  final String? machineName;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final double? litresDispensed;
  final DateTime createdAt;
  final String? paymentId;
  final String description;

  TransactionModel({
    required this.id,
    required this.userId,
    this.machineId,
    this.machineName,
    required this.type,
    required this.status,
    required this.amount,
    this.litresDispensed,
    required this.createdAt,
    this.paymentId,
    required this.description,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      machineId: map['machineId'],
      machineName: map['machineName'],
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.waterPurchase,
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      litresDispensed: map['litresDispensed']?.toDouble(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      paymentId: map['paymentId'],
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'machineId': machineId,
      'machineName': machineName,
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'litresDispensed': litresDispensed,
      'createdAt': createdAt,
      'paymentId': paymentId,
      'description': description,
    };
  }
}

// ============ CHAT MESSAGE MODEL ============
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isSupport;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isSupport,
    this.isRead = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      isSupport: map['isSupport'] ?? false,
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp,
      'isSupport': isSupport,
      'isRead': isRead,
    };
  }
}
