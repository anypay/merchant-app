# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.




# SETUP for ios DEVICES:

$ open ios/Runner.xcodeproj/

- Select Runner (nested in Project, not in Targets)
- Select 'Build Settings'
- Click "+"
- Click "Add User-Defined Setting"
- Add FLUTTER_ROOT as the key and add the result of the following as the value:

$ which flutter | sed 's/.\{11\}$//'
(should be something like /Users/neil/.flutter)
(`which flutter` should result in the binary, and the flutter root, should be one dir up)

- Select Runner (nested in Project, not in Targets)
- Select 'Info'
- Under configurations, open each one up and set the value to 'None'
- (make sure it says "No configurations set" on each item)
- Close Xcode

$ flutter clean
$ flutter pub get
$ rm -rf ~/Library/Developer/Xcode/DerivedData/
$ cd ios;rm -rf Pods/ Podfile Podfile.lock ; pod install; cd ..
$ flutter build ios
$ open ios/Runner.xcworkspace





( those commands as a one liner ):
flutter clean; flutter pub get; rm -rf ~/Library/Developer/Xcode/DerivedData/; cd ios;rm -rf Pods/ Podfile Podfile.lock ; pod install; cd ..; flutter build ios; open ios/Runner.xcworkspace



# Building for iOS:
# (usually these steps will work, but sometimes you need to go back and run the steps above 

```
flutter build ios; open ios/Runner.xcworkspace
```


- Select Product > Destination > Generic iOS Device
- Select Product > Archive






# Building for Android:


# Do some set up:
    #TODO write setup for android building


# BEFORE YOU BUILD:
update the version code (Y) in the pubspec.yml (2.X.X+Y)

# To build for the android store, run:
flutter build appbundle --release --target-platform android-arm,android-arm64,android-x64

# To build for android devices
flutter build apk --release



