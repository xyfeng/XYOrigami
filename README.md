# XYOrigami

XYOrigami is an simple and easy-to-use view transition for iOS app. Inspired by HonCheng’s next train [video](http://www.honcheng.com/2012/02/Playing-with-folding-navigations), XYOrigami is a simpler version of folding transition. It is an add-on category of UIView, with two functions you can animate showing/hiding another view.

## Features
* Category of UIView
* Customize the number of paper folds
* Support two opening directions
* Easy adjust animation duration
* Completion block call back function
* ARC(Automatic Reference Counting) support

## Installation
* Drag the XYOrigami/XYOrigami folder into your project.
* Add the QuartzCore framework to your project.

## Usage
(see example Xcode project in /Demo)

### Open view transition
	[self.centerView showOrigamiTransitionWith:self.sideView
								 NumberOfFolds:2
									  Duration:0.5
									 Direction:XYOrigamiDirectionFromRight
									completion:^(BOOL finished) {
										NSLog(@"animation completed.");
									}];

### Close view transition:
	[self.centerView hideOrigamiTransitionWith:self.sideView
								 NumberOfFolds:2
									  Duration:0.5
									 Direction:XYOrigamiDirectionFromRight
									completion:^(BOOL finished) {
										NSLog(@"animation completed.");
									}];
## Demo
(see demo video on [Vimeo](http://vimeo.com/42979668))

![image](https://github.com/xyfeng/XYOrigami/raw/master/Demo/Demo.gif)

## Credit
XYOrigami is brought to you by [XY Feng](http://xystudio.cc/)