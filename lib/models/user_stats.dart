import 'package:hive/hive.dart';
import 'dart:math' as math;

part 'user_stats.g.dart';

@HiveType(typeId: 3)
class UserStats extends HiveObject {
  @HiveField(0)
  double? height;

  @HiveField(1)
  double? neck;

  @HiveField(2)
  double? waist;

  @HiveField(3)
  String? name;

  UserStats({this.height, this.neck, this.waist, this.name});

  UserStats copyWith({
    double? height,
    double? neck,
    double? waist,
    String? name,
  }) {
    return UserStats(
      height: height ?? this.height,
      neck: neck ?? this.neck,
      waist: waist ?? this.waist,
      name: name ?? this.name,
    );
  }

  double? calculateBMI(double weight) {
    if (height == null || height == 0) return null;
    return weight / ((height! / 100) * (height! / 100));
  }

  double? calculateBodyFat(double weight) {
    if (height == null || neck == null || waist == null) return null;
    if (height == 0 || neck == 0 || waist == 0) return null;
    if (waist! <= neck!) return 0; // Avoid log of negative or zero

    // Navy Body Fat Formula (for men)
    // 495 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(height)) - 450
    final log10waistNeck = math.log(waist! - neck!) / math.log(10);
    final log10height = math.log(height!) / math.log(10);

    double bodyFat =
        495 / (1.0324 - 0.19077 * log10waistNeck + 0.15456 * log10height) - 450;
    return bodyFat.clamp(0, 100);
  }
}
