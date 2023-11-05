# TBTabBarController

TBTabBarController is a versatile iOS framework that provides a customizable tab bar controller for managing multiple child view controllers. It offers support for both horizontal and vertical tab bar layouts, giving you the flexibility to design your app's navigation according to your specific needs. It provides you with the tools to design your app's navigation to suit your unique requirements.

While TBTabBarController has class names and methods that resemble their UIKit counterparts, most of these classes, including `TBTabBarController`, `TBTabBar`, and `TBTabBarButton`, are custom implementations. Their similarity in names and method signatures is for development convenience. These components are not related to their UIKit counterparts and offer fully custom implementations.

## Inspired by Tweetbot

TBTabBarController is inspired by the implementation used in the popular Tweetbot iOS application. It draws inspiration from the innovative and user-friendly tab bar navigation of Tweetbot, aiming to provide a similar level of flexibility and customization for your iOS apps.

## Overview

TBTabBarController empowers you to create a seamless and tailored user navigation experience within your iOS app. Enjoy the flexibility, customization, and convenience that this framework provides. TBTabBarController offers the following key features:

- **Horizontal and Vertical Tab Bars:** TBTabBarController includes both horizontal and vertical tab bars, which can be automatically selected based on the view's size class or manually configured.

- **Custom Tab Bar Items:** You can add custom tab bar items to the tab bar, enabling you to include non-functional buttons or other custom elements in your tab bar layout.

- **Tab Bar Placement Control:** The framework provides methods for controlling the placement of the tab bar, including options for hiding, changing side, and animating these transitions.

- **Custom Transition Animations:** You can provide your custom animation controller to control the transition between view controllers when a new tab is selected.

For more detailed information, you can refer to the code comments and class descriptions included in the TBTabBarController framework.

## Usage

To get started with TBTabBarController, you can create an instance of `TBTabBarController` and customize it to meet your app's navigation requirements. You can manage the child view controllers and tab bar items using the provided methods.

```swift
import TBTabBarController

// Initialize TBTabBarController
let tabBarController = TBTabBarController()

// Add view controllers to the tab bar controller
tabBarController.viewControllers = [
    UINavigationController(rootViewController: UIViewController()),
    UIViewController(),
    ...
]

// Set the tab bar controller as the root view controller
window.rootViewController = tabBarController
window.makeKeyAndVisible()
```

## Example

For a more in-depth understanding of how to use `TBTabBarController`, please refer to the example project included in this repository.

## Warning

The internal implementation of the controller may involve potentially unsafe and non-obvious aspects during development, as the framework uses method swizzling extensively (leading to possible unintended side effects). Additionally, it traverses the hierarchy of nested navigation bars to determine their heights. Despite these considerations, using this framework in your app should not pose a risk during the App Store review process and can be seamlessly integrated into existing applications.

If you encounter any issues, need assistance, or wish to contribute to the development of TBTabBarController, please don't hesitate to reach out. You can create issues or pull requests on the project's GitHub repository, or you can contact me directly via email at avcdocntr@gmail.com or on Telegram at @ooooconsumer. Your feedback and contributions are highly appreciated.

## Contributing

If you encounter any issues, wish to contribute improvements, or have suggestions, we encourage you to create an issue or a pull request. We value your feedback and contributions!

## License

This project is licensed under the MIT License. Refer to the LICENSE file for details.
