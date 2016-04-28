//
//  UIView+myline.h
//  clear sky
//
//  Created by Colin on 16/3/17.
//  Copyright © 2016年 Colin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myline :UIView

-(void) drawline: (UIImageView*) image;

-(void) setPoint: (int)x1 ybegin:(int)y1 xend:(int)x2 yend:(int)y2;

-(void) setLineColor: (double)R Green:(double)G Black:(double)B Alpha:(double)alpha;

-(void) setLinesize: (double)linesize;

-(void) setLineColor:(UIColor*) color;

@end
