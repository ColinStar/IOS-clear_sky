//
//  ThridView.m
//  clear sky
//
//  Created by Colin on 16/3/9.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "ThridView.h"
#import "MainView.h"

#define IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO)
@interface ThridView()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UITabBarControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *_imageView,*comment_img1,*comment_img2,*comment_img3,*comment_img4,*comment_img5,*comment_img6,*comment_img7,*comment_img8;
    NSArray* location,* comment_arr;
    NSMutableArray * Data;
    UILabel* local;
    UITextView * describe;
    UITableViewCell *tvc;
    UILabel *textLabel1;
    UISwitch *switchview1,*switchview2;
    UITapGestureRecognizer *singleTap;
    NSInteger count;
    NSIndexPath * index;
}

@property UITableView *tv;
@property NSString* localname;
@property(nonatomic,strong) IBOutlet UITextField *textfield1,*textfield2;
@property (nonatomic , strong)CLLocationManager *locationManager;

@end

@implementation ThridView
@synthesize tv = _tv;
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self checkphoto];
    self.view.backgroundColor = [UIColor grayColor];
    
    //定位服务
    //定位初始化
    location = [[NSArray alloc]init];
    _locationManager=[[CLLocationManager alloc] init];
    _locationManager.delegate=self;
    [self locate];
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleDone target:self action:@selector(SendData)];
    
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonpress)];
    singleTap.delegate = self;
    
    comment_img1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, 80, 65, 65)];
    comment_img2 = [[UIImageView alloc]initWithFrame:CGRectMake(90, 80, 65, 65)];
    comment_img3 = [[UIImageView alloc]initWithFrame:CGRectMake(165, 80, 65, 65)];
    comment_img4 = [[UIImageView alloc]initWithFrame:CGRectMake(240, 80, 65, 65)];
    comment_img5 = [[UIImageView alloc]initWithFrame:CGRectMake(15, 150, 65, 65)];
    comment_img6 = [[UIImageView alloc]initWithFrame:CGRectMake(90, 150, 65, 65)];
    comment_img7 = [[UIImageView alloc]initWithFrame:CGRectMake(165, 150, 65, 65)];
    comment_img8 = [[UIImageView alloc]initWithFrame:CGRectMake(240, 150, 65, 65)];
    
    comment_arr = [[NSArray alloc]initWithObjects:comment_img1,comment_img2,comment_img3,comment_img4,comment_img5,comment_img6,comment_img7,comment_img8, nil];
    comment_img1.image = [UIImage imageNamed:@"complaint-add.png"];
    count = 0;
    index = [NSIndexPath indexPathForRow:0 inSection:0];
    
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
    self.tabBarController.delegate = self;
    
    _tv = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tv.dataSource = self;
    _tv.delegate = self;
    _tv.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UITapGestureRecognizer *hidden = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    hidden.delegate = self;
    hidden.cancelsTouchesInView = NO;
    [_tv addGestureRecognizer:hidden];
    
    [self.view addSubview:_tv];
}

#pragma mark -定位
- (void) locate{
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        //定位初始化
        [_locationManager startUpdatingLocation];//开启定位
        _localname = @"定位中";
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

             _localname = placemark.name;
             NSLog(@ "定位完成:%@",_localname);
             if (_localname) {
                 textLabel1.text = _localname;
             }
             //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
             [manager stopUpdatingLocation];
         }else if (error == nil && [array count] == 0)
         {
             _localname = @"重新定位";
             NSLog(@"No results were returned.");
         }else if (error != nil)
         {
             _localname = @"重新定位";
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


#pragma mark - 响应事件
- (void)checkphoto{
    if (IOS8) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"获取图片"  message:nil  preferredStyle:UIAlertControllerStyleActionSheet];
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                // 相机
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.allowsEditing = YES;
                imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePickerController animated:YES completion:^{}];
                
            }];
            
            [alertController addAction:defaultAction];
        }
        
        UIAlertAction *defaultAction1 = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // 相册
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePickerController animated:YES completion:^{}];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        
        
        [alertController addAction:cancelAction];
        
        [alertController addAction:defaultAction1];
        
        //弹出视图 使用UIViewController的方法
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{
        UIActionSheet *sheet;
        
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            sheet  = [[UIActionSheet alloc] initWithTitle:@"获取图片" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
            
        }else {
            sheet  = [[UIActionSheet alloc] initWithTitle:@"获取图片" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
        }
        
        if ([window.subviews containsObject:self.view]) {
            [sheet showInView:self.view];
        } else {
            [sheet showInView:window];
        }

    }
    
}


#pragma mark - 调用UIActionSheet iOS7使用
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSUInteger sourceType = 0;
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 0:
                // 取消
                return;
            case 1:
                // 相机
                sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
            case 2:
                // 相册
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
        }
    } else {
        
        if (buttonIndex == 1) {
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
    }
    
    // 跳转到相机或相册页面
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}

#pragma mark - iOS7 iOS8都要调用方法，选择完成后调用该方法。
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // 保存图片至本地，上传图片到服务器需要使用
    [self saveImage:image withName:@"avatar.png"];
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"avatar.png"];
    
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    
    //设置图片显示
    if (count == 3) {
        [_tv reloadRowsAtIndexPaths:[NSArray arrayWithObjects:index,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (count < 7) {
        [comment_arr[count] setImage:savedImage];
        [comment_arr[count+1] setImage:[UIImage imageNamed:@"complaint-add.png"]];
        [comment_arr[count] removeGestureRecognizer:singleTap];
        [comment_arr[count+1] addGestureRecognizer:singleTap];
        count++;
    }
    else {
        [comment_arr[count] setImage:savedImage];
        [comment_arr[count] removeGestureRecognizer:singleTap];
    }
//    [comment_img1 setImage:savedImage];
}

#pragma mark - iOS7 iOS8都要调用方法，按取消按钮用该方法。
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 1);//1为不缩放保存，取值（0.0-1.0）
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:fullPath atomically:NO];
}

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//     int index = tabBarController.selectedIndex;
//    if (index == 2) {
//        [self checkphoto];
//    }
//}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    tvc = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (tvc == nil) {
        tvc = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        tvc.textLabel.font = [UIFont systemFontOfSize:13.0];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                describe = [[UITextView alloc]initWithFrame:CGRectMake(5, 5, 320, 75)];
                describe.delegate = self;
                
                comment_img1.userInteractionEnabled = YES;
                comment_img2.userInteractionEnabled = YES;
                comment_img3.userInteractionEnabled = YES;
                comment_img4.userInteractionEnabled = YES;
                comment_img5.userInteractionEnabled = YES;
                comment_img6.userInteractionEnabled = YES;
                comment_img7.userInteractionEnabled = YES;
                comment_img8.userInteractionEnabled = YES;
                
                [comment_img1 addGestureRecognizer:singleTap];
                
                [tvc addSubview:comment_img1];
                [tvc addSubview:comment_img2];
                [tvc addSubview:comment_img3];
                [tvc addSubview:comment_img4];
                [tvc addSubview:comment_img5];
                [tvc addSubview:comment_img6];
                [tvc addSubview:comment_img7];
                [tvc addSubview:comment_img8];
                
                [tvc addSubview:describe];
                
            }
            else if (indexPath.row == 1){
                UIImageView *imageview1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 25, 25)];
                textLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(40 , 10 ,280, 20)];
                textLabel1.text = _localname;
                textLabel1.font = [UIFont systemFontOfSize:13.0];
                imageview1.image = [UIImage imageNamed:@"ios7-location-outline.png"];
                [tvc addSubview:textLabel1];
                [tvc addSubview:imageview1];
            }
            else if (indexPath.row == 2){
                UIImageView *imageview2 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 25, 25)];
                _textfield1 = [[UITextField alloc]initWithFrame:CGRectMake(40, 10, 280, 20)];
                _textfield1.font = [UIFont systemFontOfSize:13.0];
                _textfield1.tag = 001;
                _textfield1.placeholder = @"添加标签，以空格分隔（必填）";
                imageview2.image = [UIImage imageNamed:@"ios7-pricetags-outline.png"];
                _textfield1.delegate = self;
                _textfield1.returnKeyType = UIReturnKeyNext;
                [tvc addSubview:imageview2];
                [tvc addSubview:_textfield1];
            }
            else if (indexPath.row == 3){
                UIImageView *imageview3 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 25, 25)];
                _textfield2 = [[UITextField alloc]initWithFrame:CGRectMake(40, 10, 280, 20)];
                _textfield2.font = [UIFont systemFontOfSize:13.0];
                _textfield2.tag = 002;
                _textfield2.placeholder = @"违规企业名称（可不填）";
                imageview3.image = [UIImage imageNamed:@"ios7-compose-outline.png"];
                _textfield2.delegate = self;
                _textfield2.returnKeyType = UIReturnKeyDone;
                [tvc addSubview:imageview3];
                [tvc addSubview:_textfield2];
            }
            
        } else {
            if (indexPath.row == 0){
                tvc.textLabel.text = @"同步分享到微信朋友圈";
                tvc.imageView.image = [UIImage imageNamed:@"umeng_socialize_wxcircle.png"];
                switchview1 = [[UISwitch alloc] initWithFrame:CGRectZero];
                tvc.accessoryView = switchview1;
            }
            else{
                tvc.textLabel.text = @"同步分享到新浪微博";
                tvc.imageView.image = [UIImage imageNamed:@"umeng_socialize_sina_on.png"];
                switchview2 = [[UISwitch alloc] initWithFrame:CGRectZero];
                tvc.accessoryView = switchview2;
            }
        }
    }
    //退出后关闭选中状态
    tvc.selectionStyle = UITableViewCellSelectionStyleNone;
    return tvc;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    } else {
        return 2;
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0) {
        if (count<3) {
            return 150;
        }
        else
            return 220;
    }
    else
        return 45;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.textfield1) {
        [self.textfield2 becomeFirstResponder];
    }
    else if(textField ==self.textfield2){
        [textField resignFirstResponder];
    }
    return YES;
}

-(void) hideKeyboard{
    [describe resignFirstResponder];
    [_textfield1 resignFirstResponder];
    [_textfield2 resignFirstResponder];
}

-(void) buttonpress{
    [self checkphoto];
}

-(NSMutableArray*) SendData{
    Data = [[NSMutableArray alloc]initWithObjects:comment_img1.image,comment_img2.image,comment_img3.image,comment_img4.image,comment_img5.image,comment_img6.image,comment_img7.image,comment_img8.image,describe.text,_textfield1.text,_textfield2.text, nil];
    NSLog(@"%@",Data);
    if(switchview1.isOn)
    {
        
    }
    if(switchview2.isOn){
        
    }
    
    return Data;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end