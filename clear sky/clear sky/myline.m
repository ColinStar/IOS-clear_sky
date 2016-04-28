//
//  UIView+myline.m
//  clear sky
//
//  Created by Colin on 16/3/17.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import "myline.h"

@interface myline()

   @property int x1,y1,x2,y2;
   @property double R,G,B,alpha;
    @property UIColor* color;
   @property (nonatomic)  double linesize;

@end

@implementation myline

-(void) drawline:(UIImageView *)image1
{
    UIGraphicsBeginImageContext(image1.frame.size);
    [image1.image drawInRect:CGRectMake(0, 0, image1.frame.size.width, image1.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), _linesize);  //线宽
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), _R / 255.0, _G / 255.0, _B / 255.0, _alpha);  //颜色
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _x1, _y1);  //起点坐标
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), _x2, _y2);   //终点坐标
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    image1.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

}

-(void) setLineColor:(UIColor*) color{
    _color = color;
    if (_color == [UIColor greenColor]) {
        _R = 0.0;
        _G = 128.0;
        _B = 0.0;
        _alpha = 1.0;
    }
    
    if (_color == [UIColor yellowColor]) {
        _R = 255.0;
        _G = 255.0;
        _B = 0.0;
        _alpha = 1.0;
    }
    
    if (_color == [UIColor orangeColor]) {
        _R = 255.0;
        _G = 165.0;
        _B = 0.0;
        _alpha = 1.0;
    }
    
    if (_color == [UIColor redColor]) {
        _R = 255.0;
        _G = 0.0;
        _B = 0.0;
        _alpha = 1.0;
    }
    
    if (_color == [UIColor purpleColor]) {
        _R = 128.0;
        _G = 0.0;
        _B = 128.0;
        _alpha = 1.0;
    }
    
    if (_color == [UIColor brownColor]) {
        _R = 165.0;
        _G = 42.0;
        _B = 42.0;
        _alpha = 1.0;
    }
    
    if (_color == [UIColor blackColor]) {
        _R = 0.0;
        _G = 0.0;
        _B = 0.0;
        _alpha = 1.0;
    }
}

-(void) setLineColor:(double)R Green:(double)G Black:(double)B Alpha:(double)alpha
{
    _R = R;
    _G = G;
    _B = B;
    _alpha = alpha;
}

-(void) setPoint:(int)x1 ybegin:(int)y1 xend:(int)x2 yend:(int)y2
{
    _x1 = x1;
    _y1 = y1;
    _x2 = x2;
    _y2 = y2;
}

-(void) setLinesize:(double)linesize
{
    _linesize = linesize;
}

@end
