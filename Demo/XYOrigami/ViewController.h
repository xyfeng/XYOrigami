//
//  ViewController.h
//  XYOrigami
//
//  Created by XY Feng on 5/28/12.
//  Copyright (c) 2012 Xiaoyang Feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *centerView;
@property (strong, nonatomic) IBOutlet MKMapView *sideView;
@property (strong, nonatomic) IBOutlet UILabel *foldsNum;
@property (strong, nonatomic) IBOutlet UILabel *durationNum;
@property (strong, nonatomic) IBOutlet UIButton *closeBtn;

@end