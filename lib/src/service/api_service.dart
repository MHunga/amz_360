import 'package:amz_360/src/models/project_info.dart';
import 'package:http/http.dart' as http;

class ApiService {
  create(String url) async {
    var body = {};
    final response = await http.post(Uri.parse(url), body: body);
  }

  Future<ProjectInfo> getProject() async {
    return ProjectInfo(
        id: "",
        title: "My City",
        author: "Mr Hung",
        description: "this is my description of my city",
        initImageId: 0,
        location: "Ha Noi, Viet Nam",
        images: [
          ProjectImage(
            id: 0,
            image:
                "https://saffi3d.files.wordpress.com/2011/08/12-marla-copy.jpg",
          ),
          ProjectImage(
              id: 1,
              image:
                  "https://saffi3d.files.wordpress.com/2011/08/commercial_area_cam_v004.jpg",
              hotspots: []),
          ProjectImage(
              id: 2,
              image:
                  "https://saffi3d.files.wordpress.com/2011/08/community-club-pano_v009.jpg",
              hotspots: []),
          ProjectImage(
              id: 3,
              image:
                  "https://saffi3d.files.wordpress.com/2011/08/enterance_gate_v0014.jpg",
              hotspots: []),
        ]);
  }
}
