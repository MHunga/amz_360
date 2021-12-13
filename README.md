# AMZ 360

AMZ 360 is a plugin that provides a 360 degree image visualizer in Flutter.

* Display via Assets.
* Display via URL.
* Display via Client of [Modernbiztech](https://www.modernbiztech.com/).

## Getting Started

# Install

In `pubspec.yaml` add to `dependencies`:

```
dependencies:
    amz_360:
        git:
            url: git@github.com:MHunga/amz_360.git
            ref: main
```

# Import

`import 'package:amz_360/amz_360.dart';`

# Usage

* To display 360 image from assets

``` 
Amz360View.asset(
          imageAsset: "assets/images/panorama.jpeg", // Link from assets
          autoRotationSpeed: 1,
          enableSensorControl: false,
          displayMode: Amz360ViewType.view360,
        )
```

* To display 360 image from url

```
Amz360View.url(
          imageUrl: "https://cdn.eso.org/images/publicationjpg/ESO_Hotel_Paranal_360_Marcio_Cabral_Chile_02-CC.jpg",
          autoRotationSpeed: 1,
          enableSensorControl: false,
          displayMode: Amz360ViewType.view360,
        )
```

* To display 360 image from url

1. Create new account from [Modernbiztech](https://www.modernbiztech.com/).

2. Get a `apiKey` from your account

3. Set `apiKey` to client

```
void main() {
  Amz360.instance.setClient("your-api-key");
  runApp(const MyApp());
}
```
4. To create new project:

```
await Amz360.instance
                  .create(
                title: "This is title of project",
                descrition: "This is descriptions of project",
                images: lisfile,
                progressCallback: (sentBytes, totalBytes) {
                  print("Progress: $sentBytes/$totalBytes");
                },
              )
```

5. To get all created projects on your account:

```
final data = await Amz360.instance.getListProject();
print(data!.data![0].id);
```

6. To display a created project

```
Amz360View.client(
          id: id, // Id of project
          autoRotationSpeed: 0.0,
          enableSensorControl: true,
          showControl: true,
          controlIcons: [
            ControlIcon(
                child: Image.asset("assets/info.png", width: 24, height: 24)),
          ],
          onTap: (long, lat, t) {
            log("$long   $lat, $t");
          },
          onLongPressStart: (long, lat, t) {
            log("$long   $lat, $t");
          },
        ),
```

# Basic properties

| Properties          | Value              |                                                |
| -----------------   | ------------------ | ---------------------------------------------- |
| autoRotationSpeed   | `double`           | visualizer auto rotation speed. default to 0.0 |
| enableSensorControl | `bool`             | use sensor to display                          |
| displayMode         | `Amz360ViewType`   | `.view360` 360 display mode, `.viewOriginalImage` Original image display mode, `.viewOnlyImageInScene` only image in Scene |
| showControl         | `bool`             | enable / disable show Control                  |




