//
//  ThridView.m
//  clear sky
//
//  Created by Colin on 16/3/9.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "ThridView.h"

#define IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO)
@interface ThridView()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UITabBarControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *_imageView;
}
@property UITableView *tv;

@end

@implementation ThridView
@synthesize tv = _tv;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkphoto];
    self.view.backgroundColor = [UIColor grayColor];
    self.tabBarController.delegate = self;
    _tv = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tv.dataSource = self;
    _tv.delegate = self;
    _tv.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [self.view addSubview:_tv];
}

#pragma mark - 按钮响应事件
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
    [_imageView setImage:savedImage];
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

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
     int index = tabBarController.selectedIndex;
    if (index == 2) {
        [self checkphoto];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *tvc = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    if (tvc == nil) {
        tvc = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                
            }
            else if (indexPath.row == 1){
                tvc.textLabel.text = @"";
            }
            else if (indexPath.row == 2){
                
            }
            else if (indexPath.row == 3){
                
            }
            
        } else {
            tvc.textLabel.font = [UIFont systemFontOfSize:12.0];
            if (indexPath.row == 0)
                tvc.textLabel.text = @"同步分享到微信朋友圈";
            else
                tvc.textLabel.text = @"同步分享到新浪微博";
        }
    }
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end