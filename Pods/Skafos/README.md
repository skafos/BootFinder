<h1 align="center">
<img src="images/skafos_horizontal_on_white.png">
</h1>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="#license">License</a>
  • <a href="#questions">Questions?</a>
</p>

Skafos is the tool for deploying machine learning models to mobile apps and managing the same models in a production environment. Built to integrate with any of the major cloud providers, users can utilize AWS, Azure, Google, IBM or nearly any other computational environment to organize data and train models. Skafos then versions, manages, deploys, and monitors model versions running in your production application environments

---

## Installation

1. Sign up for Skafos account at [Skafos](https://skafos.io)
2. Create a ML project using Skafos dashboard at [Quickstart](http://dashboard.metismachine.io/quickstart/project)
3. Configure your app to use Skafos, including enable background updates via push notifications.

### CocoaPods
[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. 
To integrate Skafos into your Xcode project using CocoaPods, specify it in your Podfile:

```ruby
pod 'Skafos', '~> 4.0.2'
```

### Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. 
To integrate Skafos into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "skafos/ios" "4.0.2"
```

---

## Usage
Inside your app delegate, add the following:

```swift
import Skafos
```

Then configure the framework with your project token:

```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  // ...

  Skafos.initialize("your project token")

  return true
}
```

Now you are all set to call Skafos and ask it to load your model.

```swift

Skafos.load("your asset name") { (error, asset) in
  if let error = error {
    print("Oh man, an error: \(error)")

    return
  }

  if let model = asset.model {
    self.classifier.model = model
  }

  for file in asset.files {
    print("File name: \(file.name) and path: \(file.path)")
  }

  // And if you have multiple MLModels you can always loop through those too:
  for model in asset.models {
    print("Model name: \(model.name), path: \(model.path), and model itself: \(model.model)")
  }
}

```


>
> Note: Swizzle is enabled by default, if you chose to disable swizzle, add `swizzle: false` to your initialize function and add the following to your app delegate:
>

```swift

 func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    Skafos.application(application, performFetchWithCompletionHandler: completionHandler)
  }

  func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
    Skafos.application(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
  }

```


## License

Skafos swift framework uses the Apache2 license, located in the LICENSE file.

## Questions?

Contact us by email <a href="mailto:..">hello@skafos.io</a>, or by twitter @skafos.
