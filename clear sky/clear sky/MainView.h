//
//  ViewController.h
//  clear sky
//
//  Created by Colin on 16/3/5.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "MJRefresh.h"

@interface MainView : UIViewController<UIScrollViewDelegate,CLLocationManagerDelegate,UIAlertViewDelegate>

-(NSString*) getlocation;

@end

