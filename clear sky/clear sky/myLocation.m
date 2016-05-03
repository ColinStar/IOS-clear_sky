//
//  myLocation.m
//  clear sky
//
//  Created by Colin on 16/4/30.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "myLocation.h"

@implementation myLocation

-(id) init{
    location = [[NSArray alloc]init];

    _locationManager=[[CLLocationManager alloc] init];
    _locationManager.delegate=self;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        [_locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization];//在后台也可定位
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    return self;
}

#pragma mark -定位
- (void) locate:(UIViewController *)View{
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        //定位初始化
        [_locationManager startUpdatingLocation];//开启定位
    }else {
        //提示用户无法进行定位操作
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"定位不成功 ,请确认开启定位" preferredStyle:  UIAlertControllerStyleAlert];
        [View presentViewController:alert animated:true completion:nil];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    [_locationManager stopUpdatingLocation];
    
    NSLog(@"location ok");
    
    CLLocation *currentLocation = [locations firstObject];
    
    NSLog(@"%@",[NSString stringWithFormat:@"经度:%3.5f 纬度:%3.5f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude]);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             //NSLog(@%@,placemark.name);//具体位置
             //获取城市
             NSString *city = placemark.locality;
             if (!city) {
                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                 city = placemark.administrativeArea;
             }
             _cityname = city;
             NSLog(@ "定位完成:%@",placemark);
             if (_cityname) {

             }
             //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
             [manager stopUpdatingLocation];
         }else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
    
    
}

/** 定位服务状态改变时调用*/
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"用户还未决定授权");
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
            } else {
                NSLog(@"定位服务关闭，不可用");
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"获得前后台授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"获得前台授权");
            break;
        }
        default:
            break;
    }
}

-(NSString*) getlocation{
    return _cityname;
}

@end
