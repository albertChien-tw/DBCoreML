# DBCoreML

[![CI Status](https://img.shields.io/travis/dabechien/DBCoreML.svg?style=flat)](https://travis-ci.org/dabechien/DBCoreML)
[![Version](https://img.shields.io/cocoapods/v/DBCoreML.svg?style=flat)](https://cocoapods.org/pods/DBCoreML)
[![License](https://img.shields.io/cocoapods/l/DBCoreML.svg?style=flat)](https://cocoapods.org/pods/DBCoreML)
[![Platform](https://img.shields.io/cocoapods/p/DBCoreML.svg?style=flat)](https://cocoapods.org/pods/DBCoreML)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

DBCoreML is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DBCoreML'
```
## Useage
upload images to server
```swift
self.mlClient.createImagesFromData(images: self.images, tagIds: tagArrs, completion: { (success) in
print(success)
})
```
train the model
```swift
self.mlClient.trainProject(completion: { (success) in
if success{
}
})
```
Finding the Latest Model Update Immediately Use the Local Model if an Error Occurs
```swift
self.mlClient.setUpModel(directory: .documentDirectory, modelName: "Landmark", localModel: Landmark().model)
```
List the pictures and tags in the model

```swift
self.mlClient.queryImage(istaged: .tagged, completion: { (photos, error) in

})
```
## Author

dabechien, remix3966@gmail.com

## License

DBCoreML is available under the MIT license. See the LICENSE file for more info.
