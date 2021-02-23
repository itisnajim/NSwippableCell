# NSwippableCell

[![CI Status](https://img.shields.io/travis/itisnajim/NSwippableCell.svg?style=flat)](https://travis-ci.org/itisnajim/NSwippableCell)
[![Version](https://img.shields.io/cocoapods/v/NSwippableCell.svg?style=flat)](https://cocoapods.org/pods/NSwippableCell)
[![License](https://img.shields.io/cocoapods/l/NSwippableCell.svg?style=flat)](https://cocoapods.org/pods/NSwippableCell)
[![Platform](https://img.shields.io/cocoapods/p/NSwippableCell.svg?style=flat)](https://cocoapods.org/pods/NSwippableCell)

## Description

An easy-to-use UICollectionViewCell subclass that implements a swipeable content view which exposes utility buttons or views

## Preview
[![Preview Video]()](https://github.com/itisnajim/NSwippableCell/blob/main/preview_video.mp4?raw=true)



## Example
[![Example Video]()](https://github.com/itisnajim/NSwippableCell/blob/main/demo_video.mov?raw=true)

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

NSwippableCell is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'NSwippableCell'
```

## Usage
### 1. Make the cell extend from NSwippableCell 

### 2. Add the right view and/or the left view:
```swift
let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? NSwippableCell;

cell?.rightRevealView = // UIButton, UIImageView or any object extend from UIView
cell?.leftRevealView = // UIButton, UIImageView or any object extend from UIView
```

## Methods and Properties
### didRevealRightView
Callback when the right view is visible
```swift
cell?.didRevealRightView = { (isVisible: Bool) in
    print("The right view is visible: "+String(isVisible));
}
```

### didRevealLeftView
Callback when the left view is visible
```swift
cell?.didRevealLeftView = { (isVisible: Bool) in
    print("The left view is visible: "+String(isVisible));
}
```

### closeRevealedView
Close/Hide the revealed view
```swift
cell?.closeRevealedView(){
    print("The revealed view is closed");
}
```

### hideRightRevealViewIfOtherOpened
Make the cell close/hide the right view when other cell (in the same UICollectionView) opened (revealed a left or a right view)
```swift
cell?.hideRightRevealViewIfOtherOpened = // true or false, default is true.
```

### hideLeftRevealViewIfOtherOpened
Make the cell close/hide the left view when other cell (in the same UICollectionView) opened (revealed a left or a right view)
```swift
cell?.hideLeftRevealViewIfOtherOpened = // true or false, default is true.
```

### doSwipe
Swipe the cell right or left programatically
```swift
cell?.doSwipe(gestureDirection: direction); // let direction: UISwipeGestureRecognizer.Direction = .right or .left
```

## Author

itisnajim, itisnajim@gmail.com

## License

NSwippableCell is available under the MIT license. See the LICENSE file for more info.
