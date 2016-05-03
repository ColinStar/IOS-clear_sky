//
//  MainView.m
//  clear sky
//
//  Created by Colin on 16/3/5.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "MainView.h"
#import "myUILabel.h"
#import "myline.h"
#import "Gauge.h"

@interface MainView ()<CLLocationManagerDelegate,UIAlertViewDelegate>
{
    UIScrollView *sv;
    
    CGFloat contentOffsetY;
    CGFloat oldContentOffsetY;
    CGFloat newContentOffsetY;
    
    UIImageView *location_img;
    UIImageView *weather_img;
    UIImageView *PM25_img,*PM10_img,*O3_img,*SO2_img,*NO2_img,*CO_img,*Wear_img,*Cold_img,*Exercise_img,*Rays_img;
    UIImageView *l4,*l5,*l6,*l7,*l8,*l9,*l10,*l11,*l12,*l13;
    
    UILabel *location_city;
    UILabel *AQI_gl;
    UILabel *info,*temperature,* humidity, *AQI_Tip,*AQI_Data,*SdAQI,*SdAQI_Tip;
    UILabel *PM25,*PM10,*O3,*SO2,*NO2,*CO,*Wear,*Cold,*Exercise,*Rays,*Wear1,*Cold1,*Exercise1,*Rays1,*Cutoff,*Cutoff_1,*Cutoff_2,*Case;
    
    NSDate * senddate;
    
    NSDateFormatter * dateformatter;
    
    NSString * locationString;
    NSString *cityname;
    NSString *PM25_data,*PM10_data,*SO2_data,*NO2_data,*O3_data,*CO_data,*Wear_data,*Cold_data,*Exercise_data,*Rays_data;
    
    NSMutableDictionary *datasouce;
    NSMutableDictionary *realtime,*life,*pm25;
    
    NSData *Data;
    
    NSInteger locationHour;
    
    NSArray* _airQArray;
    NSArray* _airQLableColor;
    NSArray* location;
    
    NSMutableArray *aqi;
    NSMutableArray *GasInfo;
    
    Gauge *AQI_gauge;
    
    myline *ml4,*ml5,*ml6,*ml7,*ml8,*ml9,*ml10,*ml11,*ml12,*ml13;

}
@property( readwrite, assign ) NSInteger aqi_int,PM25_int,PM10_int,O3_int,NO2_int,SO2_int,CO_int;
@property( readwrite, assign ) NSInteger aqi_level,PM25_level,PM10_level,O3_level,NO2_level,SO2_level,CO_level,Cold_level,Exercise_level,Wear_level,Rays_level;
@property (nonatomic , strong)CLLocationManager *locationManager;
@property UIScrollView *sv;
@end

@implementation MainView
    @synthesize sv = _sv;

- (void)viewDidLoad {
    _airQArray = @[@"优",@"良",@"轻度",@"中度",@"重度",@"严重",@"爆表"];
    _airQLableColor = @[[UIColor greenColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor redColor],[UIColor purpleColor],[UIColor brownColor],[UIColor blackColor]];
    
    [super viewDidLoad];

    [[JHOpenidSupplier shareSupplier] registerJuheAPIByOpenId:@"JH2b91ce40529ced93ce21e306040579c5"];
//定位服务
//定位初始化
    location = [[NSArray alloc]init];
    _locationManager=[[CLLocationManager alloc] init];
    _locationManager.delegate=self;
    //  _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    //  _locationManager.distanceFilter=10;
    [self locate];
    
//滚动屏幕初始化
    sv = [[UIScrollView alloc]initWithFrame:
                        CGRectMake(0, 0, 320, 568)];
    sv.contentSize = CGSizeMake(320, 1136);
    self.navigationController.navigationBar.translucent = YES;
    
//    是否分页
    sv.pagingEnabled = FALSE;
    sv.showsVerticalScrollIndicator = FALSE;
    sv.showsHorizontalScrollIndicator = FALSE;
    
    sv.delegate = self;
    
    sv.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟延迟加载数据，因此1秒后才调用（真实开发中，可以移除这段gcd代码）
        [self performSelectorOnMainThread:@selector(loadNewData) withObject:nil waitUntilDone:YES];
        [sv setFrame:CGRectMake(sv.frame.origin.x, sv.frame.origin.y+80, sv.frame.size.width, sv.frame.size.height)];
            // 结束刷新
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 结束刷新
            [sv setFrame:CGRectMake(sv.frame.origin.x, sv.frame.origin.y-80, sv.frame.size.width, sv.frame.size.height)];
            [sv.mj_header endRefreshing];

        });
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    sv.mj_header.automaticallyChangeAlpha = YES;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        [_locationManager requestWhenInUseAuthorization];
        //[_locationManager requestAlwaysAuthorization];//在后台也可定位
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
    
    location_img = [[UIImageView alloc]initWithFrame:CGRectMake(110, 78, 25, 25)];
    location_city = [[UILabel alloc]initWithFrame:CGRectMake(140, 80, 60, 20)];
    location_city.textAlignment = NSTextAlignmentLeft;
    
    [self updateinit];
    
    UILabel *AQI = [[UILabel alloc]initWithFrame:CGRectMake(20, 330, 100, 100)];
    UILabel *AQI_Head = [[UILabel alloc]initWithFrame:CGRectMake(30, 335, 80, 20)];
    AQI_Tip = [[UILabel alloc]initWithFrame:CGRectMake(125, 410, 20, 20)];
    AQI_Data = [[UILabel alloc]initWithFrame:CGRectMake(30, 365, 80, 60)];
    
    AQI_Head.text = @"空气质量指数";
    AQI_Head.font = [UIFont systemFontOfSize:12];
    AQI_Head.textColor = [UIColor whiteColor];
    AQI_Head.textAlignment = NSTextAlignmentCenter;
    
    AQI_Data.text = @"";
    AQI_Data.font = [UIFont fontWithName:@ "Arial Rounded MT Bold" size:(42.0)];
    AQI_Data.textColor = [UIColor whiteColor];
    AQI_Data.textAlignment = NSTextAlignmentCenter;
    
    AQI_Tip.text = @"";
    AQI_Tip.backgroundColor = [UIColor greenColor];
    AQI_Tip.textAlignment = NSTextAlignmentCenter;
    
    AQI_Head.backgroundColor = AQI_Data.backgroundColor =[UIColor clearColor];
    AQI.backgroundColor = [UIColor colorWithRed:167.0/255 green:207.0/255 blue:248.0/255 alpha:0.5];
    
//画线
    UIImageView *l1=[[UIImageView alloc] initWithFrame:self.view.frame];
    myline *ml1 = [[myline alloc]init];
    [ml1 setPoint:0 ybegin:455 xend:320 yend:455];
    [ml1 setLineColor:255.0 Green:255.0 Black:255.0 Alpha:1.0];
    [ml1 setLinesize:2.0];
    [ml1 drawline:l1];
    
    UIImageView *l2=[[UIImageView alloc] initWithFrame:self.view.frame];
    myline *ml2 = [[myline alloc]init];
    [ml2 setPoint:110 ybegin:465 xend:110 yend:505];
    [ml2 setLineColor:255.0 Green:255.0 Black:255.0 Alpha:1.0];
    [ml2 setLinesize:2.0];
    [ml2 drawline:l2];
    
    UIImageView *l3=[[UIImageView alloc] initWithFrame:self.view.frame];
    myline *ml3 = [[myline alloc]init];
    [ml3 setPoint:220 ybegin:465 xend:220 yend:505];
    [ml3 setLineColor:255.0 Green:255.0 Black:255.0 Alpha:1.0];
    [ml3 setLinesize:2.0];
    [ml3 drawline:l3];
    

    UIImageView *image4 = [[UIImageView alloc]initWithFrame:CGRectMake(150, 500, 20, 20)];

    image4.image= [UIImage imageNamed:@"ios7-arrow-down.png"];
    
    UIImageView *image5 = [[UIImageView alloc]initWithFrame:CGRectMake(115, 465, 50, 40)];
    image5.image = [UIImage imageNamed:@"temperature.png"];
    
    UIImageView *image6 = [[UIImageView alloc]initWithFrame:CGRectMake(250, 475, 20, 20)];
    image6.image = [UIImage imageNamed:@"humidity.png"];
    
    weather_img = [[UIImageView alloc]initWithFrame:CGRectMake(25, 475, 20, 20)];
    
    info = [[UILabel alloc]initWithFrame:CGRectMake(50, 475, 40, 20)];
    temperature = [[UILabel alloc]initWithFrame:CGRectMake(165, 475, 30,20)];
    humidity = [[UILabel alloc]initWithFrame:CGRectMake(280, 475, 30, 20)];
//    info.backgroundColor = humidity.backgroundColor = temperature.backgroundColor = [UIColor redColor];
    info.textColor = temperature.textColor = humidity.textColor = [UIColor whiteColor];
    info.font = humidity.font= temperature.font= [UIFont systemFontOfSize:12];
    info.textAlignment = humidity.textAlignment = temperature.textAlignment = NSTextAlignmentCenter;
    
//第二视图
    Cutoff = [[UILabel alloc]initWithFrame:CGRectMake(10, 650, 300, 40)];
    Cutoff.layer.cornerRadius = 5;
    Cutoff.clipsToBounds = YES;
    Cutoff_1 = [[UILabel alloc]initWithFrame:CGRectMake(20, 650, 135, 40)];
    Cutoff_1.text = @"大气指标";
    Cutoff_1.font =[UIFont fontWithName:@ "Arial Rounded MT Bold" size:(15.0)];
    Cutoff_1.textAlignment = NSTextAlignmentCenter;
    Cutoff_2 = [[UILabel alloc]initWithFrame:CGRectMake(165, 650, 135, 40)];
    Cutoff_2.text = @"健康建议";
    Cutoff_2.textAlignment = NSTextAlignmentCenter;
    Cutoff_2.font =[UIFont fontWithName:@ "Arial Rounded MT Bold" size:(15.0)];
    
    Case = [[UILabel alloc]initWithFrame:CGRectMake(10, 710, 300, 320)];
    Case.layer.cornerRadius = 5;
    Case.clipsToBounds = YES;
    
    PM25_img = [[UIImageView alloc]initWithFrame:CGRectMake(20, 700, 75, 70)];
    PM10_img = [[UIImageView alloc]initWithFrame:CGRectMake(20, 750, 75, 70)];
    O3_img = [[UIImageView alloc]initWithFrame:CGRectMake(20, 800, 75, 70)];
    SO2_img = [[UIImageView alloc]initWithFrame:CGRectMake(20, 850, 75, 70)];
    NO2_img = [[UIImageView alloc]initWithFrame:CGRectMake(20, 900, 75, 70)];
    CO_img = [[UIImageView alloc]initWithFrame:CGRectMake(20, 950, 75, 70)];
    
    Cold_img = [[UIImageView alloc]initWithFrame:CGRectMake(175, 725, 25, 25)];
    Exercise_img = [[UIImageView alloc]initWithFrame:CGRectMake(175, 775, 25, 25)];
    Wear_img = [[UIImageView alloc]initWithFrame:CGRectMake(175, 820, 35, 35)];
    Rays_img = [[UIImageView alloc]initWithFrame:CGRectMake(175, 870, 30, 30)];
    
    Cold1 = [[UILabel alloc]initWithFrame:CGRectMake(210, 710, 60, 30)];
    Exercise1 = [[UILabel alloc]initWithFrame:CGRectMake(210, 760, 60, 30)];
    Wear1 = [[UILabel alloc]initWithFrame:CGRectMake(210, 810, 60, 30)];
    Rays1 = [[UILabel alloc]initWithFrame:CGRectMake(210, 860, 60, 30)];
    Cold1.text = @"感冒指数";
    Exercise1.text = @"锻炼指数";
    Wear1.text = @"穿衣指数";
    Rays1.text = @"紫外指数";
    Cold1.textAlignment = Exercise1.textAlignment = Wear1.textAlignment = Rays1.textAlignment = NSTextAlignmentLeft;
    Cold1.font = Exercise1.font = Wear1.font = Rays1.font =[UIFont systemFontOfSize:12];
    
    Cold = [[UILabel alloc]initWithFrame:CGRectMake(260, 730, 40, 20)];
    Exercise = [[UILabel alloc]initWithFrame:CGRectMake(260, 780, 40, 20)];
    Wear = [[UILabel alloc]initWithFrame:CGRectMake(260, 830, 40, 20)];
    Rays = [[UILabel alloc]initWithFrame:CGRectMake(260, 880, 40, 20)];
    Cold.textAlignment = Exercise.textAlignment = Wear.textAlignment = Rays.textAlignment = NSTextAlignmentRight;
    Cold.font = Exercise.font = Wear.font = Rays.font =[UIFont systemFontOfSize:11];
    
    PM25 = [[UILabel alloc]initWithFrame:CGRectMake(100, 720, 50, 50)];
    PM10 = [[UILabel alloc]initWithFrame:CGRectMake(100, 770, 50, 50)];
    O3 = [[UILabel alloc]initWithFrame:CGRectMake(100, 820, 50, 50)];
    SO2 = [[UILabel alloc]initWithFrame:CGRectMake(100, 870, 50, 50)];
    NO2 = [[UILabel alloc]initWithFrame:CGRectMake(100, 920, 50, 50)];
    CO = [[UILabel alloc]initWithFrame:CGRectMake(100, 970, 50, 50)];
    
    
    l4=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml4 = [[myline alloc]init];
    [ml4 setPoint:20 ybegin:755 xend:140 yend:755];
    [ml4 setLinesize:2.0];
    
    l5=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml5 = [[myline alloc]init];
    [ml5 setPoint:20 ybegin:805 xend:140 yend:805];
    [ml5 setLinesize:2.0];
    
    l6=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml6 = [[myline alloc]init];
    [ml6 setPoint:20 ybegin:855 xend:140 yend:855];
    [ml6 setLinesize:2.0];
    
    l7=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml7 = [[myline alloc]init];
    [ml7 setPoint:20 ybegin:905 xend:140 yend:905];
    [ml7 setLinesize:2.0];
    
    l8=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml8 = [[myline alloc]init];
    [ml8 setPoint:20 ybegin:955 xend:140 yend:955];
    [ml8 setLinesize:2.0];
    
    l9=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml9 = [[myline alloc]init];
    [ml9 setPoint:20 ybegin:1005 xend:140 yend:1005];
    [ml9 setLinesize:2.0];
    
    l10=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml10 = [[myline alloc]init];
    [ml10 setPoint:170 ybegin:755 xend:300 yend:755];
    [ml10 setLinesize:2.0];
    
    l11=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml11 = [[myline alloc]init];
    [ml11 setPoint:170 ybegin:805 xend:300 yend:805];
    [ml11 setLinesize:2.0];
    
    l12=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml12 = [[myline alloc]init];
    [ml12 setPoint:170 ybegin:855 xend:300 yend:855];
    [ml12 setLinesize:2.0];
    
    l13=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 1136)];
    ml13 = [[myline alloc]init];
    [ml13 setPoint:170 ybegin:905 xend:300 yend:905];
    [ml13 setLinesize:2.0];
    
    AQI_gauge = [[Gauge alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
    AQI_gauge.center = CGPointMake(240, 968);
    
    AQI_gl = [[UILabel alloc]initWithFrame:CGRectMake(216, 970, 50, 50)];
    AQI_gl.text = @"";
    AQI_gl.textAlignment = NSTextAlignmentCenter;
    AQI_gl.font = [UIFont fontWithName:@ "Arial Rounded MT Bold" size:(25.0)];
    AQI_gl.textColor = [UIColor whiteColor];

#pragma mark -增加控件
    [self.view addSubview:sv];
    [sv addSubview:l1];
    [sv addSubview:l2];
    [sv addSubview:l3];
    [sv addSubview:image4];
    [sv addSubview:image5];
    [sv addSubview:image6];

    [sv addSubview:location_img];
    [sv addSubview:location_city];
    
    [sv addSubview:info];
    [sv addSubview:weather_img];
    [sv addSubview:temperature];
    [sv addSubview:humidity];
    
    [sv addSubview:AQI];
    [sv addSubview:AQI_Head];
    [sv addSubview:AQI_Tip];
    [sv addSubview:AQI_Data];
    [sv addSubview:AQI_gl];
    
    [sv addSubview:Cutoff];
    [sv addSubview:Cutoff_1];
    [sv addSubview:Cutoff_2];
    
    [sv addSubview:Case];
    
    [sv addSubview:PM25_img];
    [sv addSubview:PM10_img];
    [sv addSubview:O3_img];
    [sv addSubview:SO2_img];
    [sv addSubview:NO2_img];
    [sv addSubview:CO_img];
    [sv addSubview:Cold_img];
    [sv addSubview:Exercise_img];
    [sv addSubview:Wear_img];
    [sv addSubview:Rays_img];
    
    [sv addSubview:PM25];
    [sv addSubview:PM10];
    [sv addSubview:O3];
    [sv addSubview:SO2];
    [sv addSubview:NO2];
    [sv addSubview:CO];
    [sv addSubview:Cold1];
    [sv addSubview:Exercise1];
    [sv addSubview:Wear1];
    [sv addSubview:Rays1];
    [sv addSubview:Cold];
    [sv addSubview:Exercise];
    [sv addSubview:Wear];
    [sv addSubview:Rays];
    
    [sv addSubview:l4];
    [sv addSubview:l5];
    [sv addSubview:l6];
    [sv addSubview:l7];
    [sv addSubview:l8];
    [sv addSubview:l9];
    [sv addSubview:l10];
    [sv addSubview:l11];
    [sv addSubview:l12];
    [sv addSubview:l13];
    
    [sv addSubview:AQI_gauge];
}

#pragma mark -Navigation下拉消失
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    newContentOffsetY = scrollView.contentOffset.y;
    
//    NSLog(@"当前偏移量%f",newContentOffsetY);
    if (scrollView.dragging) {  // 拖拽
        if (oldContentOffsetY-newContentOffsetY <0 && oldContentOffsetY >=0 &&contentOffsetY !=568)
        {// 向下滚动
            sv.contentOffset = CGPointMake(0, 568);
            self.tabBarController.tabBar.hidden = YES;
    }
        if (oldContentOffsetY-newContentOffsetY >0 && oldContentOffsetY >=0 &&contentOffsetY !=0)
        {  //向上滚动
            sv.contentOffset = CGPointMake(0, 0);
            self.tabBarController.tabBar.hidden = NO;
        }
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    contentOffsetY = scrollView.contentOffset.y;
//    NSLog(@"contentOffsetY%f",contentOffsetY);
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    oldContentOffsetY = scrollView.contentOffset.y;
//    NSLog(@"oldContentOffsetY%f",oldContentOffsetY);
}

#pragma mark -第二视图
-(void) secondinit{
    PM25.font = PM10.font = O3.font = SO2.font = NO2.font = CO.font =
    [UIFont fontWithName:@ "Arial Rounded MT" size:(20.0)];
    
    PM25.textAlignment = PM10.textAlignment = O3.textAlignment = SO2.textAlignment = NO2.textAlignment = CO.textAlignment = NSTextAlignmentCenter;
    
    PM25.text = PM25_data;
    PM10.text = PM10_data;
    O3.text = O3_data;
    NO2.text = NO2_data;
    SO2.text = SO2_data;
    CO.text = CO_data;

    [AQI_gauge setGaugeValue:_aqi_int animation:YES];
}

#pragma mark -更新视图
-(void) updateinit{
    senddate=[NSDate date];
    dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"HH"];
    locationString=[dateformatter stringFromDate:senddate];
    
    locationHour = [locationString intValue];
    
    if (locationHour <=6  || locationHour>= 17) {
        self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"home-bg.png"] ];
        location_city.textColor = [UIColor whiteColor];
        location_img.image= [UIImage imageNamed:@"ios7-location-light.png"];
        Cutoff.backgroundColor = Case.backgroundColor =[UIColor colorWithRed:235.0/255 green:236.0/255 blue:237.0/255 alpha:0.5];
        PM25_img.image =[UIImage imageNamed:@"PM2.5_light.png"];
        PM10_img.image =[UIImage imageNamed:@"PM10_light.png"];
        O3_img.image =[UIImage imageNamed:@"O3_light.png"];
        SO2_img.image =[UIImage imageNamed:@"SO2_light.png"];
        NO2_img.image =[UIImage imageNamed:@"NO2_light.png"];
        CO_img.image =[UIImage imageNamed:@"CO_light.png"];
        Cold_img.image = [UIImage imageNamed:@"Cold_light.png"];
        Exercise_img.image = [UIImage imageNamed:@"Exercise_light.png"];
        Wear_img.image = [UIImage imageNamed:@"Wear_light.png"];
        Rays_img.image = [UIImage imageNamed:@"Rays_light.png"];
        
        PM25.textColor = PM10.textColor = O3.textColor = SO2.textColor = NO2.textColor = CO.textColor = Cold.textColor = Cold1.textColor =  Exercise.textColor = Exercise1.textColor =  Wear.textColor = Wear1.textColor =  Rays.textColor = Rays1.textColor = [UIColor whiteColor];
    }
    else {
        self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"home-bg-light.jpg"] ];
        location_city.textColor = [UIColor blackColor];
        location_img.image= [UIImage imageNamed:@"ios7-location-black.png"];
        Cutoff.backgroundColor = Case.backgroundColor = [UIColor colorWithRed:128.0/255 green:129.0/255 blue:130.0/255 alpha:0.5];
        PM25_img.image =[UIImage imageNamed:@"PM2.5.png"];
        PM10_img.image =[UIImage imageNamed:@"PM10.png"];
        O3_img.image =[UIImage imageNamed:@"O3.png"];
        SO2_img.image =[UIImage imageNamed:@"SO2.png"];
        NO2_img.image =[UIImage imageNamed:@"NO2.png"];
        CO_img.image =[UIImage imageNamed:@"CO.png"];
        Cold_img.image = [UIImage imageNamed:@"Cold.png"];
        Exercise_img.image = [UIImage imageNamed:@"Exercise.png"];
        Wear_img.image = [UIImage imageNamed:@"Wear.png"];
        Rays_img.image = [UIImage imageNamed:@"Rays.png"];
        
        PM25.textColor = PM10.textColor = O3.textColor = SO2.textColor = NO2.textColor = CO.textColor = Cold.textColor = Cold1.textColor =  Exercise.textColor = Exercise1.textColor =  Wear.textColor = Wear1.textColor =  Rays.textColor = Rays1.textColor = [UIColor blackColor];
    }
    Cutoff_1.backgroundColor =Cutoff_2.backgroundColor = [UIColor clearColor];
    location_img.backgroundColor = [UIColor clearColor];}

#pragma mark -下拉刷新
-(void)loadNewData{
    [self locate];
    if (cityname) {
    [self updateinit];
//    NSLog(@"asdfdfhjkdsfjjkfjknjn");
    //api调用
    NSString *path = @"http://op.juhe.cn/onebox/weather/query";
    NSString *api_id = @"73";
    NSString *method = @"HTTPS GET";
    NSDictionary *param = @{@"cityname":cityname,@"key":@"bed1ef10b8853da5db9f0500233b50ec", @"dtype":@"json"};
    JHAPISDK *juheapi = [JHAPISDK shareJHAPISDK];
    datasouce = [[NSMutableDictionary alloc]init];
    [juheapi executeWorkWithAPI:path
                          APIID:api_id
                     Parameters:param
                         Method:method
                        Success:^(id responseObject){
                            if ([[param objectForKey:@"dtype"] isEqualToString:@"xml"]) {
                                NSLog(@"***xml*** \n %@",responseObject);
                            }else{
                                int error_code = [[responseObject objectForKey:@"error_code"] intValue];
                                if (!error_code) {
                                    datasouce= [NSMutableDictionary dictionaryWithDictionary:responseObject];
                                    //调回子线程
                                    //[NSThread detachNewThreadSelector:@selector(loadJason) toTarget:self withObject:nil]
                                    //调到主线程
                                    [self performSelectorOnMainThread:@selector(loadJason) withObject:nil waitUntilDone:YES];
                                }else{
                                    NSLog(@" %@", responseObject);
                                }
                            }
                        } Failure:^(NSError *error) {
                            NSLog(@"error:   %@",error.description);
                        }];
    }
    else
    {
        UIAlertView * UA = [[UIAlertView alloc]initWithTitle:@"警告" message:@"未获取定位" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [UA show];
    }

}

#pragma mark -解析json
- (void) loadJason
{
    //json解析
    NSMutableDictionary * result = [NSMutableDictionary dictionaryWithDictionary:[datasouce objectForKey:@"result"]];
    NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary:[result objectForKey:@"data"]];
//    NSMutableDictionary * weather = [NSMutableDictionary dictionaryWithDictionary:[data objectForKey:@"weather"]];
    realtime = [NSMutableDictionary dictionaryWithDictionary:[data objectForKey:@"realtime"]];
    life = [NSMutableDictionary dictionaryWithDictionary:[data objectForKey:@"life"]];
    
//pm2.5获取
    NSError *error;
    //加载一个NSURL对象
    NSString *gcityname = [cityname substringWithRange:NSMakeRange(0, [cityname length] - 1)];
    //中文转URLEncode
    gcityname =(NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)gcityname,(CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",NULL,kCFStringEncodingUTF8));
    NSString *s = [NSString stringWithFormat:@"http://aqi.zjut.party/%@",gcityname];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:s]];
    //将请求的url数据放到NSData对象中
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *weatherDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    NSMutableArray *weatherInfo = [weatherDic objectForKey:@"nearest"];
    GasInfo = [weatherDic objectForKey:@"iaqi"];
//    NSLog(@" %@",response);
    aqi = [[NSMutableArray alloc]init];
    aqi = weatherInfo[0];
//    pm25 = [NSMutableDictionary dictionaryWithDictionary:[data objectForKey:@"pm25"]];
    [self loadweather];
    [self loadPM25];

}

#pragma mark -加载pm25
- (void) loadPM25
{
//    NSMutableDictionary * pm = [NSMutableDictionary dictionaryWithDictionary:[pm25 objectForKey:@"pm25"]];
//    NSLog(@"%@",[aqi valueForKey:@"aqi"]);
    
//PM2.5
    NSArray *apm25 = [[NSArray alloc]init];
    apm25 = GasInfo[0];
    PM25_data = [NSString stringWithFormat:@"%@",[apm25 valueForKey:@"v"][0]];
    _PM25_int = [PM25_data intValue];
    
//PM10
    NSArray *apm10 = [[NSArray alloc]init];
    apm10 = GasInfo[1];
    PM10_data = [NSString stringWithFormat:@"%@",[apm10 valueForKey:@"v"][0]];
    _PM10_int = [PM10_data intValue];

//O3
    NSArray *aO3 = [[NSArray alloc]init];
    aO3 = GasInfo[2];
    O3_data = [NSString stringWithFormat:@"%@",[aO3 valueForKey:@"v"][0]];
    _O3_int = [O3_data intValue];

//NO2
    NSArray *aNO2 = [[NSArray alloc]init];
    aNO2 = GasInfo[3];
    NO2_data = [NSString stringWithFormat:@"%@",[aNO2 valueForKey:@"v"][0]];
    _NO2_int = [NO2_data intValue];
    
//SO2
    NSArray *aSO2 = [[NSArray alloc]init];
    aSO2 = GasInfo[4];
    SO2_data = [NSString stringWithFormat:@"%@",[aSO2 valueForKey:@"v"][0]];
    _SO2_int = [SO2_data intValue];
    
//CO
    NSArray *aCO = [[NSArray alloc]init];
    aCO = GasInfo[5];
    CO_data = [NSString stringWithFormat:@"%@",[aCO valueForKey:@"v"][0]];
    _CO_int = [CO_data intValue];
    
//aqi
    NSString *aqi_data = [aqi valueForKey:@"aqi"];
    AQI_gl.text = aqi_data;
    _aqi_int = [aqi_data intValue];
    
    if (_aqi_int <= 99){
        AQI_Data.font = [UIFont fontWithName:@ "Arial Rounded MT Bold" size:(50.0)];
    }
    else{
        AQI_Data.font = [UIFont fontWithName:@ "Arial Rounded MT Bold" size:(42.0)];
    }
    AQI_Data.text =aqi_data;
    
//加载level
    [self loadlevel];
    
//图标相关处理
    [self secondinit];
    //aqi等级字体
    if (_aqi_level >= 2) {
        AQI_Tip.font = [UIFont systemFontOfSize:9];
    }
    else
        AQI_Tip.font = [UIFont systemFontOfSize:15];
    
    if (_aqi_level == 6) {
        AQI_Tip.textColor = [UIColor whiteColor];
    }
    else
        AQI_Tip.textColor = [UIColor blackColor];
    AQI_Tip.backgroundColor = _airQLableColor[_aqi_level];

    //等级指示线
    [ml4 setLineColor:_airQLableColor[_PM25_level]];
    [ml4 drawline:l4];
    
    [ml5 setLineColor:_airQLableColor[_PM10_level]];
    [ml5 drawline:l5];
    
    [ml6 setLineColor:_airQLableColor[_O3_level]];
    [ml6 drawline:l6];
    
    [ml7 setLineColor:_airQLableColor[_SO2_level]];
    [ml7 drawline:l7];
    
    [ml8 setLineColor:_airQLableColor[_NO2_level]];
    [ml8 drawline:l8];
    
    [ml9 setLineColor:_airQLableColor[_CO_level]];
    [ml9 drawline:l9];
    
    [ml10 setLineColor:_airQLableColor[_Cold_level]];
    [ml10 drawline:l10];
    
    [ml11 setLineColor:_airQLableColor[_Exercise_level]];
    [ml11 drawline:l11];
    
    [ml12 setLineColor:_airQLableColor[_Wear_level]];
    [ml12 drawline:l12];
    
    [ml13 setLineColor:_airQLableColor[_Rays_level]];
    [ml13 drawline:l13];


}

#pragma mark-加载等级
-(void) loadlevel{
//AQI等级
    if (_aqi_int>0 && _aqi_int<=50) {
        AQI_Tip.text= _airQArray[0];
        _aqi_level=0;
    }
    else if (_aqi_int>50 && _aqi_int<=100){
        AQI_Tip.text=_airQArray[1];
        _aqi_level=1;
    }
    else if (_aqi_int>100 && _aqi_int<=150){
        AQI_Tip.text=_airQArray[2];
        _aqi_level=2;
    }
    else if (_aqi_int>150 && _aqi_int<=200){
        AQI_Tip.text=_airQArray[3];
        _aqi_level=3;
    }
    else if (_aqi_int>200 && _aqi_int<=300){
        AQI_Tip.text=_airQArray[4];
        _aqi_level=4;
    }
    else if (_aqi_int>300){
        AQI_Tip.text=_airQArray[5];
        _aqi_level=5;
    }

//PM2.5等级
    if (_PM25_int>0 && _PM25_int<=35) {
        _PM25_level=0;
    }
    else if (_PM25_int>35 && _PM25_int<=75){
        _PM25_level=1;
    }
    else if (_PM25_int>75 && _PM25_int<=115){
        _PM25_level=2;
    }
    else if (_PM25_int>115 && _PM25_int<=150){
        _PM25_level=3;
    }
    else if (_PM25_int>150 && _PM25_int<=250){
        _PM25_level=4;
    }
    else if (_PM25_int>250 && _PM25_int<=500){
        _PM25_level=5;
    }
    else if (_PM25_int>500){
        _PM25_level=6;
    }
    
//PM10等级
    if (_PM10_int>0 && _PM10_int<=50) {
        _PM10_level=0;
    }
    else if (_PM10_int>50 && _PM10_int<=150){
        _PM10_level=1;
    }
    else if (_PM10_int>150 && _PM10_int<=250){
        _PM10_level=2;
    }
    else if (_PM10_int>250 && _PM10_int<=350){
        _PM10_level=3;
    }
    else if (_PM10_int>350 && _PM10_int<=420){
        _PM10_level=4;
    }
    else if (_PM10_int>420 && _PM10_int<=600){
        _PM10_level=5;
    }
    else if (_PM10_int>600){
        _PM10_level=6;
    }
    
//O3等级
    if (_O3_int>0 && _O3_int<=160) {
        _O3_level=0;
    }
    else if (_O3_int>160 && _O3_int<=200){
        _O3_level=1;
    }
    else if (_O3_int>200 && _O3_int<=300){
        _O3_level=2;
    }
    else if (_O3_int>300 && _O3_int<=400){
        _O3_level=3;
    }
    else if (_O3_int>400 && _O3_int<=800){
        _O3_level=4;
    }
    else if (_O3_int>800){
        _O3_level=5;
    }

//SO2等级
    if (_SO2_int>0 && _SO2_int<=150) {
        _SO2_level=0;
    }
    else if (_SO2_int>150 && _SO2_int<=500){
        _SO2_level=1;
    }
    else if (_SO2_int>500 && _SO2_int<=650){
        _SO2_level=2;
    }
    else if (_SO2_int>650 && _SO2_int<=800){
        _SO2_level=3;
    }
    else if (_SO2_int>800 && _SO2_int<=1600){
        _SO2_level=4;
    }
    else if (_SO2_int>1600){
        _SO2_level=5;
    }
    
//NO2等级
    if (_NO2_int>0 && _NO2_int<=100) {
        _NO2_level=0;
    }
    else if (_NO2_int>100 && _NO2_int<=200){
        _NO2_level=1;
    }
    else if (_NO2_int>200 && _NO2_int<=700){
        _NO2_level=2;
    }
    else if (_NO2_int>700 && _NO2_int<=1200){
        _NO2_level=3;
    }
    else if (_NO2_int>1200 && _NO2_int<=2300){
        _NO2_level=4;
    }
    else if (_NO2_int>2300){
        _NO2_level=5;
    }
    
//CO等级
    if (_CO_int>0 && _CO_int<=5000) {
        _CO_level=0;
    }
    else if (_CO_int>5000 && _CO_int<=10000){
        _CO_level=1;
    }
    else if (_CO_int>10000 && _CO_int<=35000){
        _CO_level=2;
    }
    else if (_CO_int>35000 && _CO_int<=60000){
        _CO_level=3;
    }
    else if (_CO_int>60000 && _CO_int<=90000){
        _CO_level=4;
    }
    else if (_CO_int>90000){
        _CO_level=5;
    }
    
//穿衣指数
    if ([Wear_data  isEqual: @"舒适"]) {
        _Wear_level=0;
    }
    else if ([Wear_data  isEqual: @"较舒适"]) {
        _Wear_level=1;
    }
    else if ([Wear_data  isEqual: @"较冷"] || [Wear_data  isEqual: @"较热"]) {
        _Wear_level=2;
    }
    else if ([Wear_data  isEqual: @"冷"] || [Wear_data  isEqual: @"热"]) {
        _Wear_level=3;
    }
    
//运动指数
    if ([Exercise_data  isEqual: @"适宜"]) {
        _Exercise_level=0;
    }
    else if ([Exercise_data  isEqual: @"较适宜"]) {
        _Exercise_level=1;
    }
    else if ([Exercise_data  isEqual: @"较不宜"]) {
        _Exercise_level=2;
    }
    else if ([Exercise_data  isEqual: @"不宜"]) {
        _Exercise_level=3;
    }
    
//感冒指数
    if ([Cold_data  isEqual: @"少发"]) {
        _Cold_level=0;
    }
    else if ([Cold_data  isEqual: @"较易发"]) {
        _Cold_level=1;
    }
    else if ([Cold_data  isEqual: @"易发"]) {
        _Cold_level=2;
    }
    else if ([Cold_data  isEqual: @"极易发"]) {
        _Cold_level=3;
    }
    
//紫外线指数
    if ([Rays_data  isEqual: @"最弱"]) {
        _Rays_level=0;
    }
    else if ([Rays_data  isEqual: @"弱"]) {
        _Rays_level=1;
    }
    else if ([Rays_data  isEqual: @"较高"]) {
        _Rays_level=2;
    }
    else if ([Rays_data  isEqual: @"中等"]) {
        _Rays_level=3;
    }
    else if ([Rays_data  isEqual: @"强"]) {
        _Rays_level=4;
    }
    else if ([Rays_data  isEqual: @"很强"]) {
        _Rays_level=5;
    }
}

#pragma mark -加载天气
- (void) loadweather
{
    NSMutableDictionary * weather = [NSMutableDictionary dictionaryWithDictionary:[realtime objectForKey:@"weather"]];
    NSMutableDictionary * life_info = [NSMutableDictionary dictionaryWithDictionary:[life objectForKey:@"info"]];
    NSString *img = [[NSString alloc]init];
    img = [[weather objectForKey:@"img"] stringByAppendingString:@".png"];
    weather_img.image= [UIImage imageNamed:img];
    info.text =[weather objectForKey:@"info"];
    temperature.text= [[weather objectForKey:@"temperature"] stringByAppendingString:@"℃"];
    humidity.text= [[weather objectForKey:@"humidity"] stringByAppendingString:@"%"];
    
    Wear_data = [life_info objectForKey:@"chuanyi"][0];
    Wear.text = Wear_data;
    Cold_data = [life_info objectForKey:@"ganmao"][0];
    Cold.text = Cold_data;
    Exercise_data = [life_info objectForKey:@"yundong"][0];
    Exercise.text = Exercise_data;
    Rays_data = [life_info objectForKey:@"ziwaixian"][0];
    Rays.text = Rays_data;
}

#pragma mark -定位
- (void) locate{
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        //定位初始化
        [_locationManager startUpdatingLocation];//开启定位
    }else {
        //提示用户无法进行定位操作
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"定位不成功 ,请确认开启定位" preferredStyle:  UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:true completion:nil];
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
             cityname = city;
             NSLog(@ "定位完成:%@",cityname);
             if (cityname) {
                location_city.text = cityname;
                [self loadNewData];
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
    return cityname;
}

/*#pragma mark -汉字转拼音
-(void) Transform:(NSString *)hanziText{
    if (hanziText.length > 0) {
        // 将中文字符串转成可变字符串
        NSMutableString *pinyinText = [[NSMutableString alloc] initWithString:hanziText];
        
        // 先转换为带声调的拼音
        CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformMandarinLatin, NO);
        NSLog(@"pinyin: %@", pinyinText); // 输出 pinyin: zhōng guó sì chuān
        
        // 再转换为不带声调的拼音
        CFStringTransform((__bridge CFMutableStringRef)pinyinText, 0, kCFStringTransformStripDiacritics, NO);
        NSLog(@"pinyin: %@", pinyinText); // 输出 pinyin: zhong guo si chuan
        
        // 转换为首字母大写拼音
        NSString *capitalPinyin = [pinyinText capitalizedString];
        NSLog(@"capitalPinyin: %@", capitalPinyin); // 输出 capitalPinyin: Zhong Guo Si Chuan
        
        // 截取首字母
        NSLog(@"the first letter is '%@'.", [capitalPinyin substringToIndex:1]); // 输出 the first letter is 'Z'.
    }
}*/

#pragma mark -结束
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
