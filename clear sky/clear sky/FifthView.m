//
//  FifthView.m
//  clear sky
//
//  Created by Colin on 16/5/3.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "FifthView.h"

@interface FifthView ()<UITableViewDataSource,UITableViewDelegate>

@property NSArray *menu,*cell;

@end

@implementation FifthView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tv = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    //列表视图数据源
    tv.dataSource=self;
    //代理设置
    tv.delegate=self;
    tv.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    NSString* menuDataPath = [[NSBundle mainBundle] pathForResource:@"Five's menu" ofType:@"plist"];
    NSString* cellDataPath = [[NSBundle mainBundle] pathForResource:@"Five's cell" ofType:@"plist"];
    _menu = [[NSArray alloc]initWithContentsOfFile:menuDataPath];
    _cell = [[NSArray alloc]initWithContentsOfFile:cellDataPath];
    
    [self.view addSubview:tv];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _menu.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* temp = [NSArray arrayWithArray:_menu[section]];
    return temp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tvc = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    //单元格样式
    tvc.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //字体大小
    tvc.textLabel.font = [UIFont systemFontOfSize:16];
    
    UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 25, 25)];
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake(40 , 10 ,280, 20)];

    
    NSArray *temp = [NSArray arrayWithArray: _menu[indexPath.section]];
    NSArray *temp1 = [NSArray arrayWithArray: _cell[indexPath.section]];
    textLabel.text= temp[indexPath.row];
    imageview.image = [UIImage imageNamed:temp1[indexPath.row]];
    //退出后关闭选中状态
    tvc.selectionStyle = UITableViewCellSelectionStyleNone;
    [tvc addSubview:imageview];
    [tvc addSubview:textLabel];
    return tvc;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

@end
