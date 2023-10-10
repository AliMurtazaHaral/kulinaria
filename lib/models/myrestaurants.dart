import 'package:hive/hive.dart';
import 'notesModel.dart';
part 'myrestaurants.g.dart';

@HiveType(typeId: 2)
class MyRestaurants {
  @HiveField(0)
  String name;
  @HiveField(1)
  String address;
  @HiveField(2)
  String phoneNumber;
  @HiveField(3)
  String website;
  @HiveField(4)
  List<dynamic> openingHours;
  @HiveField(5)
  String imgUrl;
  @HiveField(6)
  double stars;
  @HiveField(7)
  List<Notes> notes;

  MyRestaurants(
      {required this.name,
      required this.address,
      required this.phoneNumber,
      required this.website,
      required this.openingHours,
      required this.imgUrl,
      required this.stars,
      required this.notes});
}
