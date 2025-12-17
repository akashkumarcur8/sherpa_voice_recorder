
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

class LoginResponse {
  final String status;
  final UserDetails details;

  LoginResponse({
    required this.status,
    required this.details,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? '',
      details: UserDetails.fromJson(json['details']),
    );
  }
}

class UserDetails {
  final String username;
  final String email;
  final String empName;
  final String storeName;
  final String userId;
  final String empType;
  final String designation;
  final String managerId;
  final String teamId;
  final String companyId;
  final String managerUserId;

  UserDetails({
    required this.username,
    required this.email,
    required this.empName,
    required this.storeName,
    required this.userId,
    required this.empType,
    required this.designation,
    this.managerId = 'NA',
    this.teamId = 'NA',
    this.companyId = 'NA',
    this.managerUserId = 'NA',
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      empName: json['emp_name'] ?? '',
      storeName: json['store_name'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      empType: json['emp_type']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
    );
  }

  UserDetails copyWith({
    String? username,
    String? email,
    String? empName,
    String? storeName,
    String? userId,
    String? empType,
    String? designation,
    String? managerId,
    String? teamId,
    String? companyId,
    String? managerUserId,
  }) {
    return UserDetails(
      username: username ?? this.username,
      email: email ?? this.email,
      empName: empName ?? this.empName,
      storeName: storeName ?? this.storeName,
      userId: userId ?? this.userId,
      empType: empType ?? this.empType,
      designation: designation ?? this.designation,
      managerId: managerId ?? this.managerId,
      teamId: teamId ?? this.teamId,
      companyId: companyId ?? this.companyId,
      managerUserId: managerUserId ?? this.managerUserId,
    );
  }
}

class ManagerInfoResponse {
  final String managerId;
  final String teamId;
  final String companyId;


  ManagerInfoResponse({
    this.managerId = 'NA',
    this.teamId = 'NA',
    this.companyId = 'NA',

  });

  factory ManagerInfoResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic> && json['errorcode'] == 'invaliduser') {
      return ManagerInfoResponse();
    } else if (json is List && json.isNotEmpty && json[0] is Map<String, dynamic>) {
      final managerData = json[0] as Map<String, dynamic>;
      return ManagerInfoResponse(
        managerId: managerData['managerid']?.toString() ?? 'NA',
        teamId: managerData['teamid']?.toString() ?? 'NA',
        companyId: managerData['companyid']?.toString() ?? 'NA',

      );
    }
    return ManagerInfoResponse();
  }
}

class ManagerUserIdResponse {
  final String managerUserId;
  final String companyId;


  ManagerUserIdResponse({
    this.managerUserId = 'NA',
    this.companyId = 'NA',

  });

  factory ManagerUserIdResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic> && json['errorcode'] == 'invaliduser') {
      return ManagerUserIdResponse();
    } else if (json is List && json.isNotEmpty && json[0] is Map<String, dynamic>) {
      final managerData = json[0] as Map<String, dynamic>;
      return ManagerUserIdResponse(
        managerUserId: managerData['userid']?.toString() ?? 'NA',
        companyId: managerData['companyid']?.toString() ?? 'NA',

      );
    }
    return ManagerUserIdResponse();
  }
}