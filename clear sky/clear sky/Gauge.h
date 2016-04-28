//
//  Gauge.h
//  GaugeDemo
//
//  Created by 海锋 周 on 12-3-27.
//  Copyright (c) 2012年 CJLU rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface Gauge : UIView
{
    UIImage *gaugeView;
    UIImageView *pointer;
    
    CGFloat maxNum;
    CGFloat minNum;
    
    CGFloat maxAngle;
    CGFloat minAngle;
    
    CGFloat gaugeValue;
    CGFloat gaugeAngle;
    
    CGFloat angleperValue;
    CGFloat scoleNum;
    
    NSMutableArray *labelArray;
    CGContextRef context;
}

@property (nonatomic,retain) UIImage *gaugeView;
@property (nonatomic,retain) UIImageView *pointer;
@property (nonatomic,retain) NSMutableArray *labelArray;
@property (nonatomic) CGContextRef context;
-(void)setGaugeValue:(CGFloat)value animation:(BOOL)isAnim;

@end
