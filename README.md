# MadridShopping
### Presentation:
This is the practice application developed for the iOS Advanced course for the [KeepCoding® Startup Bootcamp Engineering Master IV](https://keepcoding.io/en/).

### Objective:
The objective is for the student to put into practice the knowledge acquired during the course iOS Advanced. The main objective is to put into practice the knowledge acquired during the course such as: persistence of data using CoreData, downloading and decoding information contained in JSON format asynchronously using NSURLSession and related classes. Produce high quality, maintainable and reliable code. Clean architecture would be valued: interactors, managers, etc.

### Requirements:
1. When starting the App for the first time, if there's Internet connection it will download all information from the Shops access point (see below), including all images.
2. The App will cache everything locally: images, data, etc. Even images of the maps. To persist information while you're offline use Core Data! You can cache the images using any technique you like (Core Data, a library, archiving files, etc.)
3. Cache is never invalidated, so once everything has been saved, set a flag and never ever access to the network again.
4. If there's no Internet connection a message will be shown to the user.
5. While caching the App will show an Activity indicator or other loader. Until you finish caching you don't get to the Main menu.
6. The app will have a main menu screen where we'll add one button & a logo. The button takes us to the list of shops.
7. The list of Shops will show in the upper 50% screen a map with one pin for each shop.
8. The list of Shops will show in the lower 50% screen. Logo to the left, background image taking all the row, shop name in the front. Tapping a row takes us to the detail shop screen.
9. All info should be read from a Core Data database.
10. If you tap on a pin in the map a callout will open with the logo +shop name. Taping the callout takes us to the detail shop screen.
11. The map will be always centered in madrid, showing also the user location.
12. All data is at least in Spanish & English: should cache all and display in Spanish (if that's our phone's language) or English otherwise.
13. Shop detail screen should show shop name, description, address and a map showing the shops's location without any pin.

### Used tools:
* Xcode 8.3.1
* swift 3.1
* Frameworks used: Core Data, MapKit
* Git
