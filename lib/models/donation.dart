class Donation {
  String? userId;
  String? petId;
  String? category;
  String? donate;
  String? regDate;
  String? petName; // Useful if your PHP joins tbl_pets

  Donation({
    this.userId,
    this.petId,
    this.category,
    this.donate,
    this.regDate,
    this.petName,
  });

  Donation.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    petId = json['pet_id'];
    category = json['category'];
    donate = json['donate'];
    regDate = json['reg_date'];
    petName = json['pet_name'] ?? "Unknown Pet";
  }
}