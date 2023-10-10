import 'package:hive/hive.dart';
part 'notesModel.g.dart';

@HiveType(typeId: 1)
class Notes {
  @HiveField(0)
  String? title;
  @HiveField(1)
  String? image;
  @HiveField(2)
  String? note;
  @HiveField(3)
  DateTime? date;
  Notes(
      {required this.title,
      required this.image,
      required this.note,
      required this.date});
}
