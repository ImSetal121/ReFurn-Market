class UserAddress {
  final int? id;
  final int? userId;
  final String? receiverName;
  final String? receiverPhone;
  final String? region;
  final bool? isDefault;
  final String? createTime;
  final String? updateTime;

  UserAddress({
    this.id,
    this.userId,
    this.receiverName,
    this.receiverPhone,
    this.region,
    this.isDefault,
    this.createTime,
    this.updateTime,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'],
      userId: json['userId'],
      receiverName: json['receiverName'],
      receiverPhone: json['receiverPhone'],
      region: json['region'],
      isDefault: json['isDefault'],
      createTime: json['createTime'],
      updateTime: json['updateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (receiverName != null) 'receiverName': receiverName,
      if (receiverPhone != null) 'receiverPhone': receiverPhone,
      if (region != null) 'region': region,
      if (isDefault != null) 'isDefault': isDefault,
      if (createTime != null) 'createTime': createTime,
      if (updateTime != null) 'updateTime': updateTime,
    };
  }

  UserAddress copyWith({
    int? id,
    int? userId,
    String? receiverName,
    String? receiverPhone,
    String? region,
    bool? isDefault,
    String? createTime,
    String? updateTime,
  }) {
    return UserAddress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      region: region ?? this.region,
      isDefault: isDefault ?? this.isDefault,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  String toString() {
    return 'UserAddress{id: $id, userId: $userId, receiverName: $receiverName, receiverPhone: $receiverPhone, region: $region, isDefault: $isDefault, createTime: $createTime, updateTime: $updateTime}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAddress &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // 获取完整地址
  String get fullAddress {
    return region ?? '';
  }

  // 是否为默认地址
  bool get isDefaultAddress => isDefault == true;
}
