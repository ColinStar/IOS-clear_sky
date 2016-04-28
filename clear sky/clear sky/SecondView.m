//
//  UIViewController+SecondView.m
//  clear sky
//
//  Created by Colin on 16/3/8.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "SecondView.h"

@interface SecondView()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *images,*titles;
    NSArray *Com;
}
@property UITableView *tv;
@property NSArray *arr;
@end

@implementation SecondView
    @synthesize tv = _tv;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self loadjson];
    _tv = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    //列表视图数据源
    _tv.dataSource=self;
    //代理设置
    _tv.delegate=self;
    _tv.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);

//loopview
//    images = @[@"h1.jpg",@"h2.jpg",@"h3.jpg",@"h4.jpg"];
//    titles = @[@"再来一次，或许你会爱上这里",@"来瞧瞧现在的涪江吧",@"变换的猝不及防",@"改造后的五云镇"];
    
    __weak __typeof(self) weakSelf = self;
    
    HYBLoopScrollView *loop = [HYBLoopScrollView loopScrollViewWithFrame:CGRectMake(0, 40, 320, 180) imageUrls:images timeInterval:5 didSelect:^(NSInteger atIndex) {
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
    } didScroll:^(NSInteger toIndex) {
    }];
    
    loop.shouldAutoClipImageToViewSize = YES;
    loop.placeholder = [UIImage imageNamed:@"default.png"];
    
    loop.alignment = kPageControlAlignRight;
    loop.adTitles = titles;
    
    [_tv setTableHeaderView:loop];
    [self.view addSubview:_tv];
}

-(void)loadjson{
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"community"ofType:@"json"];
    //根据文件路径读取数据
    NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
    NSDictionary *ComDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    Com = [[NSArray alloc]init];
    Com = [ComDic objectForKey:@"community"];
    NSArray *title = [[NSArray alloc]init];
    title = [ComDic objectForKey:@"title"];
    images = [[NSMutableArray alloc]init];
    titles = [[NSMutableArray alloc]init];
    for (int i =0 ; i<title.count; i++) {
        images[i] = [title[i] objectForKey:@"title_img"];
        titles[i] = [title[i] objectForKey:@"title"];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *tvc = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (tvc == nil) {
        tvc = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            //单元格样式
//      tvc.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSString *content = [Com[indexPath.section] objectForKey:@"text"];
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(320, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
        
        UIView *Role = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
        UIImageView *Image_Detail = [[UIImageView alloc]initWithFrame:CGRectMake(0, 60, 320, 150)];
        UIView *Issue = [[UIView alloc]initWithFrame:CGRectMake(0, 210, 320, 20)];
        UITextView *text = [[UITextView alloc]initWithFrame:CGRectMake(0, 230, 320, size.height+30)];
        UIView *Interaction = [[UIView alloc]initWithFrame:CGRectMake(0, 230+size.height+30, 320, 30)];
        
        UILabel *maintitle = [[UILabel alloc]initWithFrame:CGRectMake(55, 4, 80, 15)];
        UILabel *Detailtitle = [[UILabel alloc]initWithFrame:CGRectMake(55, 23, 130, 10)];
        UILabel *timelabel = [[UILabel alloc]initWithFrame:CGRectMake(270, 5, 40, 10)];
        UILabel *topic = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 280, 20)];
        UIImageView *topic_icon =[[UIImageView alloc]initWithFrame:CGRectMake(2, 2, 12, 15)];
        
        UIImageView *head = [[UIImageView alloc]initWithFrame:CGRectMake(2, 2, 48, 48)];
        
        UIButton *like = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 90, 20)];

        UIButton *comment = [[UIButton alloc]initWithFrame:CGRectMake(100, 5, 90, 20)];
        UIButton *share = [[UIButton alloc]initWithFrame:CGRectMake(195, 5, 60, 20)];
        
        UIButton *store = [[UIButton alloc]initWithFrame:CGRectMake(260, 5, 60, 20)];
        
        maintitle.font = [UIFont systemFontOfSize:15];
        maintitle.text = [Com[indexPath.section] objectForKey:@"name"];
        Detailtitle.font =[UIFont systemFontOfSize:12];
        Detailtitle.text = [Com[indexPath.section] objectForKey:@"time"];
        timelabel.font =[UIFont systemFontOfSize:10];
        timelabel.text = [Com[indexPath.section] objectForKey:@"tag"];
        timelabel.textColor = [UIColor grayColor];
        topic.font = [UIFont systemFontOfSize:12];
        NSString *topic1 = @"话题： ";
        NSString *topic2 = [Com[indexPath.section] objectForKey:@"topic"];
        topic.text = [topic1 stringByAppendingString:topic2];
        timelabel.textAlignment = Detailtitle.textAlignment = maintitle.textAlignment = topic.textAlignment=  NSTextAlignmentLeft;
        
        topic_icon.image = [UIImage imageNamed:@"bulb.png"];
        head.image = [UIImage imageNamed:[Com[indexPath.section] objectForKey:@"headpath"]];
        Image_Detail.image = [UIImage imageNamed:[Com[indexPath.section] objectForKey:@"imgpath"]];
        
        text.text = content;
        text.editable = NO;
        text.font = [UIFont systemFontOfSize:12];
        text.layer.borderColor = UIColor.grayColor.CGColor;
        text.layer.borderWidth = 0.5;
        text.scrollEnabled = NO;
//喜欢
        [like.imageView setContentMode:UIViewContentModeLeft];
        [like setImageEdgeInsets:UIEdgeInsetsMake(0.0,0.0,0.0,25.0)];
        [like setImage:[UIImage imageNamed:@"ios7-heart-outline.png"]forState:UIControlStateNormal];
        
        [like.titleLabel setContentMode:UIViewContentModeRight];
        NSString *temp1 = @"喜欢  ";
        NSString *temp2 = [temp1 stringByAppendingString:[Com[indexPath.section] objectForKey:@"like"]];
        
        [like setTitle:[temp2 stringByAppendingString:@"人"] forState:UIControlStateNormal];
        [like setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        like.titleLabel.font = [UIFont fontWithName:@ "STHeitiSC-Light" size:10.0];
        [like setTitleEdgeInsets:UIEdgeInsetsMake(0.0,0.0,0.0,10.0)];
//评论
        [comment.imageView setContentMode:UIViewContentModeLeft];
        [comment setImageEdgeInsets:UIEdgeInsetsMake(0.0,0.0,0.0,25.0)];
        [comment setImage:[UIImage imageNamed:@"comment.png"]forState:UIControlStateNormal];
        
        [comment.titleLabel setContentMode:UIViewContentModeRight];
        temp1 = @"评论  ";
        temp2 = [temp1 stringByAppendingString:[Com[indexPath.section] objectForKey:@"comment"]];
        [comment setTitle:[temp2 stringByAppendingString:@"人"] forState:UIControlStateNormal];
        [comment setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        comment.titleLabel.font = [UIFont systemFontOfSize: 10];
        [comment setTitleEdgeInsets:UIEdgeInsetsMake(0.0,0.0,0.0,10.0)];
//分享
        [share.imageView setContentMode:UIViewContentModeLeft];
        [share setImageEdgeInsets:UIEdgeInsetsMake(0.0,0.0,0.0,25.0)];
        [share setImage:[UIImage imageNamed:@"share.png"]forState:UIControlStateNormal];
        
        [share.titleLabel setContentMode:UIViewContentModeRight];
        [share setTitle:@"分享" forState:UIControlStateNormal];
        [share setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        share.titleLabel.font = [UIFont systemFontOfSize: 10];
        [share setTitleEdgeInsets:UIEdgeInsetsMake(0.0,0.0,0.0,10.0)];
//收藏
        [store.imageView setContentMode:UIViewContentModeLeft];
        [store setImageEdgeInsets:UIEdgeInsetsMake(0.0,0.0,0.0,25.0)];
        [store setImage:[UIImage imageNamed:@"ios7-star-outline.png"]forState:UIControlStateNormal];
        
        [store.titleLabel setContentMode:UIViewContentModeRight];
        [store setTitle:@"收藏" forState:UIControlStateNormal];
        [store setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        store.titleLabel.font = [UIFont systemFontOfSize: 10];
        [store setTitleEdgeInsets:UIEdgeInsetsMake(0.0,0.0,0.0,10.0)];
        
        [tvc addSubview:Role];
        [tvc addSubview:Image_Detail];
        [tvc addSubview:Issue];
        [tvc addSubview:text];
        [tvc addSubview:Interaction];
        
        [Role addSubview:maintitle];
        [Role addSubview:Detailtitle];
        [Role addSubview:timelabel];
        [Role addSubview:head];
        [Issue addSubview:topic];
        [Issue addSubview:topic_icon];
        [Interaction addSubview:like];
        [Interaction addSubview:comment];
        [Interaction addSubview:share];
        [Interaction addSubview:store];
        
        tvc.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return tvc;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return Com.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    // 用何種字體進行顯示
    UIFont *font = [UIFont systemFontOfSize:12];
    // 該行要顯示的內容
    NSString *content = [Com[indexPath.section] objectForKey:@"text"];
    // 計算出顯示完內容需要的最小尺寸
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(320, 1000.0f) lineBreakMode:UILineBreakModeWordWrap];
    // 這裏返回需要的高度
    return 230+size.height+30+30;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
