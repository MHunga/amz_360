export 'src/scene/scene_view.dart';
export 'src/view/amz_360_view.dart';
export 'src/view/menu_control.dart';

import 'package:amz_360/src/models/project_info.dart';
import 'package:amz_360/src/service/api_service.dart';

class Amz360 {
  static final Amz360 shared = Amz360();

  ApiService api = ApiService();

  // Create new project
  create({required ProjectInfo projectInfo}) async {
    String url = "";
    await api.create(url);
  }

  //
  edit() {}

  //
  delete(String id) {}
}
