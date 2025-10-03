class CallModel {
  final String roomId;
  final String callerUid;
  final String calleeUid;
  String status;
  String createdAt;
  String updatedAt;

  CallModel({
    required this.roomId,
    required this.callerUid,
    required this.calleeUid,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      roomId: json['roomId'],
      callerUid: json['callerUid'],
      calleeUid: json['calleeUid'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'callerUid': callerUid,
      'calleeUid': calleeUid,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
