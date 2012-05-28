//
//  ViewController.m
//  XYOrigami
//
//  Created by XY Feng on 5/28/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Origami.h"

@interface ViewController ()
{
    BOOL currDirection;
}
@end

@implementation ViewController
@synthesize centerView;
@synthesize sideView;
@synthesize foldsNum;
@synthesize durationNum;
@synthesize closeBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 40.7310;
    zoomLocation.longitude= -73.9977;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 10000, 10000);         
    [self.sideView setRegion:viewRegion animated:NO];
    
    currDirection = XYOrigamiDirectionFromLeft;
}

- (void)viewDidUnload
{
    [self setCenterView:nil];
    [self setSideView:nil];
    [self setFoldsNum:nil];
    [self setDurationNum:nil];
    [self setCloseBtn:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (IBAction)swipeLeft:(id)sender {
    if (currDirection == XYOrigamiDirectionFromLeft) {
        self.closeBtn.hidden = YES;
        [self.centerView hideOrigamiTransitionWith:self.sideView
                                     NumberOfFolds:[self.foldsNum.text intValue]
                                          Duration:[self.durationNum.text floatValue]
                                         Direction:XYOrigamiDirectionFromLeft
                                        completion:^(BOOL finished) {
                                        }];
    }
    else {
        [self.centerView showOrigamiTransitionWith:self.sideView
                                     NumberOfFolds:[self.foldsNum.text intValue]
                                          Duration:[self.durationNum.text floatValue]
                                         Direction:XYOrigamiDirectionFromRight
                                        completion:^(BOOL finished) {
                                            self.closeBtn.hidden = NO;
                                        }];
    }
}

- (IBAction)swipeRight:(id)sender {
    if (currDirection == XYOrigamiDirectionFromLeft) {
        [self.centerView showOrigamiTransitionWith:self.sideView
                                     NumberOfFolds:[self.foldsNum.text intValue] 
                                          Duration:[self.durationNum.text floatValue]
                                         Direction:XYOrigamiDirectionFromLeft
                                        completion:^(BOOL finished) {
                                            self.closeBtn.hidden = NO;
                                        }];
    }
    else {
        self.closeBtn.hidden = YES;
        [self.centerView hideOrigamiTransitionWith:self.sideView
                                     NumberOfFolds:[self.foldsNum.text intValue]
                                          Duration:[self.durationNum.text floatValue]
                                         Direction:XYOrigamiDirectionFromRight
                                        completion:^(BOOL finished) {
                                        }];
    }
}

- (IBAction)showMap:(id)sender {
    [self.centerView showOrigamiTransitionWith:self.sideView
                                 NumberOfFolds:[self.foldsNum.text intValue]
                                      Duration:[self.durationNum.text floatValue]
                                     Direction:currDirection
                                    completion:^(BOOL finished) {
                                        self.closeBtn.hidden = NO;
                                    }];
}

- (IBAction)foldNumberChanged:(UIStepper *)stepper {
    self.foldsNum.text = [NSString stringWithFormat:@"%d",(int)stepper.value];
}

- (IBAction)durationSliderChanged:(UISlider *)slider {
    self.durationNum.text = [NSString stringWithFormat:@"%.1f", slider.value];
}

- (IBAction)directionSelectorChanged:(UISegmentedControl*)seg 
{
    if (seg.selectedSegmentIndex == 0) {
        currDirection = XYOrigamiDirectionFromLeft;
        self.closeBtn.frame = CGRectMake(20, 405, 40, 30);
    }
    else {
        currDirection = XYOrigamiDirectionFromRight;
        self.closeBtn.frame = CGRectMake(260, 405, 40, 30);
    }
}

- (IBAction)hideMap:(id)sender {
    self.closeBtn.hidden = YES;
    [self.centerView hideOrigamiTransitionWith:self.sideView
                                 NumberOfFolds:[self.foldsNum.text intValue]
                                      Duration:[self.durationNum.text floatValue]
                                     Direction:currDirection
                                    completion:^(BOOL finished) {
                                    }];
}

@end
