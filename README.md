# Commando

l33t commandos don't wear undies and never use the mouse!

![Demo](https://github.com/cloudkite/Commando/raw/master/demo.gif)

## Features
####`esc` key
- Commando roll out of UITextFields/UITextViews
- Commando roll out of UIAlertviews

####`f` key
- Be a f'ng ninja. Find all tapable fields on screen - badass [vimium](http://vimium.github.io/) style

####`delete` key
- Pop a cap in UINavigationController (trigger back button item)

####`arrow` keys
- Real commandos use crossbows. Scroll the 'default' (largest frame) UIScrollView

## Installation
Use the wonderful [CocoaPods](http://github.com/CocoaPods/CocoaPods).

In your Podfile
>`pod 'Commando'`

To listen to keyboard events your app must use the `CMDCommandoApplication` custom UIApplication subclass. You can reliably leave that in for release as any non-simulator builds will only compile to an empty UIApplication subclass.
In your `main.m` :

``` objc
#import "CMDCommandoApplication.h"

int main(int argc, char *argv[]) {
   @autoreleasepool {
       return UIApplicationMain(argc, argv,
           NSStringFromClass([CMDCommandoApplication class]),
           NSStringFromClass([MYAppDelegate class]));
   }
}
```

## TODO
- Improve heuristic for finding tapable views. ie filter out views that are obscured, userInteractionDisabled etc.
- Add view debugging commands ala [DCIntrospect](https://github.com/logicreative/DCIntrospect-ARC)
- Select specific UIScrollView to scroll
- Tab between tapable UIViews ordered by view frame, then hit enter key to tap,
- UIPanGestureRecognizer, UISwipeGestureRecognizer support
- UIWebView support

## Credits
- Inspired by [vimium](http://vimium.github.io/)
- Code for listening to keyboard events [ORSimulatorKeyboardAccessor](https://github.com/orta/ORSimulatorKeyboardAccessor)
- Code for creating fake UITouches [KIF](https://github.com/kif-framework/KIF)
