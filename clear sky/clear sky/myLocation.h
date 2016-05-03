//
//  myLocation.h
//  clear sky
//
//  Created by Colin on 16/4/30.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <UIKit/UIKit.h>

@interface myLocation : CLLocation<CLLocationManagerDelegate,UIAlertViewDelegate>
{
    NSArray* location;
}

@property NSString* cityname;
@property (nonatomic , strong)CLLocationManager *locationManager;
- (id)init;
- (void) locate:(UIViewController *)View;
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
;
-(NSString*) getlocation;


@end
