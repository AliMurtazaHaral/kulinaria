// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'myrestaurants.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MyRestaurantsAdapter extends TypeAdapter<MyRestaurants> {
  @override
  final int typeId = 2;

  @override
  MyRestaurants read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MyRestaurants(
      name: fields[0] as String,
      address: fields[1] as String,
      phoneNumber: fields[2] as String,
      website: fields[3] as String,
      openingHours: (fields[4] as List).cast<dynamic>(),
      imgUrl: fields[5] as String,
      stars: fields[6] as double,
      notes: (fields[7] as List).cast<Notes>(),
    );
  }

  @override
  void write(BinaryWriter writer, MyRestaurants obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.website)
      ..writeByte(4)
      ..write(obj.openingHours)
      ..writeByte(5)
      ..write(obj.imgUrl)
      ..writeByte(6)
      ..write(obj.stars)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyRestaurantsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
