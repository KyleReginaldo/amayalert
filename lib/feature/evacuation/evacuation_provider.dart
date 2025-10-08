import 'package:amayalert/feature/evacuation/evacuation_center_model.dart';

import '../../core/constant/constant.dart';
import '../../core/result/result.dart';

class EvacuationProvider {
  Future<Result<List<EvacuationCenter>>> getEvacuationCenters() async {
    try {
      final response = await supabase
          .from('evacuation_centers')
          .select()
          .order('created_at', ascending: false);
      List<EvacuationCenter> centers = [];

      for (var e in response) {
        centers.add(EvacuationCenterMapper.fromMap(e));
      }
      return Result.success(centers);
    } catch (e) {
      return Result.error(e.toString());
    }
  }
}
