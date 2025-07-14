
class StockClass {
   // StockClass class represents a stock order in the system.
    int? id;
    String referenceNumber;
    DateTime date;
    String status;
    double total;
    int itemsCount;
    String createdBy;
    int? shopId;
    String? businessId;
    String? supplierId;
    String? companyName;

    StockClass({
      this.id,
      required this.referenceNumber,
      required this.date,
      required this.status,
      required this.total,
      required this.itemsCount,
      required this.createdBy,
      this.shopId,
      this.businessId,
      this.supplierId,
      this.companyName,
    });

    factory StockClass.fromMap(Map<String, dynamic> map) {
      return StockClass(
        id: map['id']?.toInt(),
        referenceNumber: map['referenceNumber'] ?? '',
        date: (map['date'] as DateTime?) ?? DateTime.now(),
        status: map['status'] ?? 'pending',
        total: (map['total'] as num?)?.toDouble() ?? 0.0,
        itemsCount: map['itemsCount']?.toInt() ?? 0,
        createdBy: map['createdBy'] ?? '',
        shopId: map['shopId']?.toInt(),
        businessId: map['businessId'],
        supplierId: map['supplierId'],
        companyName: map['companyName'],
      );
    }

    Map<String, dynamic> toMap() {
      return {
        'id': id,
        'referenceNumber': referenceNumber,
        'date': date.toIso8601String(),
        'status': status,
        'total': total,
        'itemsCount': itemsCount,
        'createdBy': createdBy,
        'shopId': shopId,
        'businessId': businessId,
        'supplierId': supplierId,
        'companyName': companyName,
      };
    }

 }     