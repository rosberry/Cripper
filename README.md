# Cripper
Customizable reusable component to get cropped image from provided one.
<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.2-orange.svg" />
</p>

## Features
- Fully customizable UI
- The possibility to use different quality images for according zoom scale
- Specify crop shape to preview
- Apply crop using bounding box or specified shape

## Using

1. Create and customize view controller as you want: 

    ```swift
    let cropViewController = CropperViewController(images: [.less(2): myLowQualityImage, 
                                                            .default: mySourceImage])
    cropViewController.clipBorderInset = 10
    cropViewController.cropOptions = [.circle()]
    cropViewController.mode = .path
    ```
2. Present view controller. Please note, that `CropperViewController` does not contain UI controls to apply or decline cropped image that allows you to present it with any way using your custom controls:

    ```swift
    navigationController?.pushViewController(viewController, animated: true)
    ```
3. Retrive a cropped image from `CropperViewController`. 
    ```swift
    @objc private func acceptCropActionTriggered() {
        guard case let .normal(image) = cropperViewController.makeCroppResult() else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        // TODO: Use provided image
    }
    ```

## Installation
### Depo

[Depo](https://github.com/rosberry/depo) is a universal dependency manager that combines Carthage, SPM and CocoaPods and provides common user interface to all of them.

To install `Cripper` via Carthage using Depo you need to add this to your `Depofile`:
```yaml
carts:
  - kind: github
    identifier: rosberry/Cripper
```


### Carthage
Create a `Cartfile` that lists the framework and run `carthage update`. Follow the [instructions](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) to add the framework to your project.

### SPM

Add SPM dependency to your Package.swift:
```swift
dependencies: [
    ...
    .package(url: "https://github.com/rosberry/Cripper")
],
targets: [
    .target(
    ...
        dependencies: [
            ...
            .product(name: "Cripper", package: "Cripper")
        ]
    )
]
```


## Authors

* Nikolay Tyunin, nikolay.tyunin@rosberry.com

## About

<img src="https://github.com/rosberry/Foundation/blob/master/Assets/full_logo.png?raw=true" height="100" />

This project is owned and maintained by [Rosberry](http://rosberry.com). We build mobile apps for users worldwide 🌏.

Check out our [open source projects](https://github.com/rosberry), read [our blog](https://medium.com/@Rosberry) or give us a high-five on 🐦 [@rosberryapps](http://twitter.com/RosberryApps).

## License

The project is available under the MIT license. See the LICENSE file for more info.
