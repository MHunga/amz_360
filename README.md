# AMZ 360

AMZ 360 is a plugin that provides a 360 degree image visualizer in Flutter.

* Display via Assets.
* Display via URL.
* Display via Client of [Modernbiztech](https://www.modernbiztech.com/).

## Getting Started

# Install

In `pubspec.yaml` add to `dependencies`:

```yaml
dependencies:
    amz_360:
        git:
            url: git@github.com:MHunga/amz_360.git
            ref: main
```

# Import

```dart
import 'package:amz_360/amz_360.dart';
```

# Usage

* To display 360 image from assets

```dart
Amz360View.asset(
          imageAsset: "assets/images/panorama.jpeg", // Link from assets
          autoRotationSpeed: 1,
          enableSensorControl: false,
          displayMode: Amz360ViewType.view360,
        )
```

* To display 360 image from url

```dart
Amz360View.url(
          imageUrl: "https://cdn.eso.org/images/publicationjpg/ESO_Hotel_Paranal_360_Marcio_Cabral_Chile_02-CC.jpg",
          autoRotationSpeed: 1,
          enableSensorControl: false,
          displayMode: Amz360ViewType.view360,
        )
```

* To display 360 image from client

1. Create new account from [Modernbiztech](https://www.modernbiztech.com/).

2. Get a `apiKey` from your account

3. Set `apiKey` to client

```dart
void main() {
  Amz360.instance.setClient("your-api-key");
  runApp(const MyApp());
}
```
4. To create new project:

```dart
await Amz360.instance
                  .create(
                title: "This is title of project",
                descrition: "This is descriptions of project",
                images: listfile,
                progressCallback: (sentBytes, totalBytes) {
                  print("Progress: $sentBytes/$totalBytes");
                },
              )
```

5. To get all created projects on your account:

```dart
final data = await Amz360.instance.getListProject();
print(data!.data![0].id);
```

6. To display a created project

```dart
Amz360View.client(
          id: id, // id of project
          textHotspotIcon:
              ControlIcon(child: const Icon(Icons.info, color: Colors.white)), // set Icon of text hotspot
          imageHotspotIcon:
              ControlIcon(child: const Icon(Icons.image, color: Colors.white)), // set Icon of image hotspot
          videoHotspotIcon: ControlIcon(
              child: const Icon(Icons.ondemand_video_rounded,
                  color: Colors.white)), // set Icon of Youtube video hotspot
          autoRotationSpeed: 0.0,
          enableSensorControl: true,
          showControl: true,
          onTap: (x, y, idImage) {
            log("$x   $y");
          },
          onLongPressStart: (x, y, idImage) async {
            log("$x   $y");
          },
        )
```
7. Update project

```dart
await Amz360.instance.updateProject(
  idProject: id, 
  title: "New title",
  description: "New description");
```

8. Delete project

```dart
await Amz360.instance.deleteProject(id: id);
```

8. Add Hotspot to project: 
    
    - Example: 
      ```dart
      ...
         onLongPressStart: (x, y, idImage) async {
            log("$x   $y");
            await Amz360.instance.addHotspotLable(
                idImage: idImage!, title: "TESST", text: "Tessst", x: x, y: y);
          },
          ...
      ```

    - Add text hotspot: Need to pass `text` value , 

       ```dart
            await Amz360.instance.addHotspotLable(
                idImage: idImage!, title: "TESST", text: "Tessst", x: x, y: y);
      ```

    - Add image hotspot: Need to pass `image` value , 

       ```dart
            await Amz360.instance.addHotspotLable(
                idImage: idImage!, title: "TESST", image: file, x: x, y: y);
      ```  

    - Add video youtube hotspot: Need to pass `idVideoYoutube` value , 

       ```dart
            await Amz360.instance.addHotspotLable(
                idImage: idImage!, title: "TESST", idVideoYoutube: "idVideoYoutube", x: x, y: y);
      ```


# Basic properties

| Properties          | Value              |                                                |
| -----------------   | ------------------ | ---------------------------------------------- |
| autoRotationSpeed   | `double`           | visualizer auto rotation speed. default to 0.0 |
| enableSensorControl | `bool`             | use sensor to display                          |
| displayMode         | `Amz360ViewType`   | `.view360` 360 display mode, `.viewOriginalImage` Original image display mode, `.viewOnlyImageInScene` only image in Scene |
| showControl         | `bool`             | enable / disable show Control                  |




