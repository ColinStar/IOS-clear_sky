//
//  ThridView.m
//  clear sky
//
//  Created by Colin on 16/3/9.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "FourthView.h"
#import "TotalComplain.h"
#import "NearComplain.h"
#import "News.h"
#import "Chart.h"
#import "Search.h"
#import "News.h"
#import "Data.h"
#import "Game.h"

@interface FourthView()<UITableViewDataSource,UITableViewDelegate>
@property NSArray *menu;
@property NSArray *cell;

@end


@implementation FourthView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    UITableView *tv = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    //列表视图数据源
    tv.dataSource=self;
    //代理设置
    tv.delegate=self;
    
    tv.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    NSString* menuDataPath = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"plist"];
    _menu =[[NSArray alloc]initWithContentsOfFile:menuDataPath];
    
    NSString* menuDataPath1 = [[NSBundle mainBundle] pathForResource:@"cell" ofType:@"plist"];
    _cell = [[NSArray alloc]initWithContentsOfFile:menuDataPath1];

    
    [self.view addSubview:tv];

}

//表格视图

//设置行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray* temp = [NSArray arrayWithArray:_menu[section]];
    return temp.count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return _menu.count;
}

//每列内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *tvc = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    //单元格样式
    tvc.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //字体大小
    tvc.textLabel.font = [UIFont systemFontOfSize:16];

    
    NSArray *temp = [NSArray arrayWithArray: _menu[indexPath.section]];
    NSArray *temp1 = [NSArray arrayWithArray: _cell[indexPath.section]];
    tvc.textLabel.text= temp[indexPath.row];
    tvc.imageView.image = [UIImage imageNamed:temp1[indexPath.row]];
    //退出后关闭选中状态
    tvc.selectionStyle = UITableViewCellSelectionStyleNone;
    return tvc;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 7;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0 && indexPath.section ==0)
    {
        [self jmp00];
    }
    
    if (indexPath.row==1 && indexPath.section ==0)
    {
        [self jmp01];
    }
    if (indexPath.row==0 && indexPath.section ==1)
    {
        [self jmp10];
    }if (indexPath.row==1 && indexPath.section ==1)
    {
        [self jmp11];
    }if (indexPath.row==0 && indexPath.section ==2)
    {
        [self jmp20];
    }
    if (indexPath.row==1 && indexPath.section ==2)
    {
        [self jmp21];
    }
    if (indexPath.row==2 && indexPath.section ==2)
    {
        [self jmp22];
    }
}

- (void)jmp00
{
    TotalComplain* ano = [[TotalComplain alloc]init];
    ano.view.backgroundColor = [UIColor whiteColor];
    ano.navigationItem.title = @"所有投诉";
    [self.navigationController pushViewController:ano animated:YES];
//     NSLog(@"跳转成功");
}

- (void)jmp01
{
    NearComplain* ano = [[NearComplain alloc]init];
    ano.view.backgroundColor = [UIColor whiteColor];
    ano.navigationItem.title = @"附近投诉";
    [self.navigationController pushViewController:ano animated:YES];
    //     NSLog(@"跳转成功");
}

- (void)jmp10
{
    Chart* ano = [[Chart alloc]init];
    ano.view.backgroundColor = [UIColor whiteColor];
    ano.navigationItem.title = @"每月报表";
    [self.navigationController pushViewController:ano animated:YES];
    //     NSLog(@"跳转成功");
}

- (void)jmp11
{
    Search* ano = [[Search alloc]init];
    ano.view.backgroundColor = [UIColor whiteColor];
    ano.navigationItem.title = @"投诉查询";
    [self.navigationController pushViewController:ano animated:YES];
    //     NSLog(@"跳转成功");
}

- (void)jmp20
{
    News* ano = [[News alloc]init];
    ano.view.backgroundColor = [UIColor whiteColor];
    ano.navigationItem.title = @"环保新闻";
    [self.navigationController pushViewController:ano animated:YES];
    //     NSLog(@"跳转成功");
}

- (void)jmp21
{
    Data* ano = [[Data alloc]init];
    ano.view.backgroundColor = [UIColor whiteColor];
    ano.navigationItem.title = @"数据中心";
    [self.navigationController pushViewController:ano animated:YES];
    //     NSLog(@"跳转成功");
}

- (void)jmp22
{
    Game* ano = [[Game alloc]init];
    ano.view.backgroundColor = [UIColor whiteColor];
    ano.navigationItem.title = @"一站到底";
    [self.navigationController pushViewController:ano animated:YES];
    //     NSLog(@"跳转成功");
}

//返回事件函数
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end