export 'src/scene/scene_view.dart';
export 'src/view/amz_360_view.dart';
export 'src/view/menu_control.dart';

import 'package:amz_360/src/models/project_info.dart';

class Amz360 {
  static final Amz360 shared = Amz360();

  // Create new project
  create({required ProjectInfo projectInfo}) {}

  //
  edit() {}

  //
  delete(String id) {}
}
