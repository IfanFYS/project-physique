import 'package:hive/hive.dart';

part 'user_stats.g.dart';

@HiveType(typeId: 3)
class UserStats extends HiveObject {
  @HiveField(0)
  double? height;

  @HiveField(1)
  double? neck;

  @HiveField(2)
  double? waist;

  UserStats({
    this.height,
    this.neck,
    this.waist,
  });

  UserStats copyWith({
    double? height,
    double? neck,
    double? waist,
  }) {
    return UserStats(
      height: height ?? this.height,
      neck: neck ?? this.neck,
      waist: waist ?? this.waist,
    );
  }

  double? calculateBMI(double weight) {
    if (height == null || height == 0) return null;
    return weight / ((height! / 100) * (height! / 100));
  }

  double? calculateBodyFat(double weight) {
    if (height == null || neck == null || waist == null) return null;
    if (height == 0 || neck == 0 || waist == 0) return null;
    
    // Navy Body Fat Formula (for men)
    double bodyFat = 495 / (1.0324 - 0.19077 * (waist! - neck!) / 100 + 0.15456 * (height! / 100)) - 450;
    return bodyFat.clamp(0, 100);
  }
}
