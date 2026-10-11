class MemberCredential {
  final String houseno;
  final String familyname;
  final String password;
  final String role;

  const MemberCredential({
    required this.houseno,
    required this.familyname,
    required this.password,
    required this.role,
  });

  factory MemberCredential.fromJson(Map<String, dynamic> j) => MemberCredential(
        houseno: j['houseno'] ?? '',
        familyname: j['familyname'] ?? '',
        password: j['password'] ?? '',
        role: j['role'] ?? 'member',
      );

  bool get isCommittee =>
      role == 'chairman' || role == 'secretary' || role == 'treasurer';
}

class FamilyMember {
  final String name;
  final String contactno;
  final String age;
  final String gender;

  const FamilyMember({
    required this.name,
    required this.contactno,
    required this.age,
    required this.gender,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> j) => FamilyMember(
        name: j['name'] ?? '',
        contactno: j['contactno'] ?? '',
        age: j['age'] ?? '',
        gender: j['gender'] ?? '',
      );
}

class MemberWithFamily {
  final String houseno;
  final String familyname;
  final List<FamilyMember> family;

  const MemberWithFamily({
    required this.houseno,
    required this.familyname,
    required this.family,
  });

  factory MemberWithFamily.fromJson(Map<String, dynamic> j) => MemberWithFamily(
        houseno: j['houseno'] ?? '',
        familyname: j['familyname'] ?? '',
        family: (j['family'] as List? ?? [])
            .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class Notice {
  final int? id;
  final String head;
  final String content;
  final String date;
  final String issueBy;

  const Notice({
    this.id,
    required this.head,
    required this.content,
    required this.date,
    required this.issueBy,
  });

  factory Notice.fromJson(Map<String, dynamic> j) => Notice(
        id: j['id'] as int?,
        head: j['head'] ?? '',
        content: j['content'] ?? '',
        date: j['date'] ?? '',
        issueBy: j['issue_by'] ?? '',
      );
}

class Complaint {
  final int? id;
  final String houseno;
  final String title;
  final String description;
  final String date;
  String status;
  String? finishDate;
  String? action;
  String? feedback;

  Complaint({
    this.id,
    required this.houseno,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    this.finishDate,
    this.action,
    this.feedback,
  });

  factory Complaint.fromJson(Map<String, dynamic> j) => Complaint(
        id: j['id'] as int?,
        houseno: j['houseno'] ?? '',
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        date: j['date'] ?? '',
        status: j['status'] ?? 'Pending',
        finishDate: j['finish_date'] as String?,
        action: j['action'] as String?,
        feedback: j['feedback'] as String?,
      );
}

class Maintenance {
  final int? id;
  final String houseno;
  final String month;
  final String year;
  final double amount;
  String status;
  String? paidDate;
  String? transactionId;
  String? familyname;

  Maintenance({
    this.id,
    required this.houseno,
    required this.month,
    required this.year,
    required this.amount,
    required this.status,
    this.paidDate,
    this.transactionId,
    this.familyname,
  });

  factory Maintenance.fromJson(Map<String, dynamic> j) => Maintenance(
        id: j['id'] as int?,
        houseno: j['houseno'] ?? '',
        month: j['month'] ?? '',
        year: j['year'] ?? '',
        amount: (j['amount'] ?? 0).toDouble(),
        status: j['status'] ?? 'Pending',
        paidDate: j['paid_date'] as String?,
        transactionId: j['transaction_id'] as String?,
        familyname: j['familyname'] as String?,
      );
}

class DashboardStats {
  final int totalMembers;
  final int pendingComplaints;
  final int totalComplaints;
  final int totalNotices;
  final int pendingMaintenance;

  const DashboardStats({
    required this.totalMembers,
    required this.pendingComplaints,
    required this.totalComplaints,
    required this.totalNotices,
    required this.pendingMaintenance,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
        totalMembers: j['total_members'] ?? 0,
        pendingComplaints: j['pending_complaints'] ?? 0,
        totalComplaints: j['total_complaints'] ?? 0,
        totalNotices: j['total_notices'] ?? 0,
        pendingMaintenance: j['pending_maintenance'] ?? 0,
      );
}
