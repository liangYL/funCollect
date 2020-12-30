//
//  MyWindow.m
//  WKAlertViewDemo
//
//  Created by 王琨 on 15-3-11.
//  Copyright (c) 2015年 王琨. All rights reserved.
//

#import "WKAlertView.h"
//按钮颜色
#define OKBUTTON_BGCOLOR [UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:1.000]
#define CANCELBUTTON_BGCOLOR [UIColor redColor]
//按钮起始tag
#define TAG 100

#define SCREEN_Width   [UIScreen mainScreen].bounds.size.width
#define SCREEN_Height   [UIScreen mainScreen].bounds.size.height

NSUInteger const Button_Size_Width = 60;
NSUInteger const Button_Size_Height = 20;

NSInteger const Title_Font = 15;
NSInteger const Detial_Font = 12;

//Logo半径（画布）
NSInteger const Logo_Size = 30;

NSInteger const Button_Font = 14;

@interface WKAlertView ()
{
    UIView * _logoView;//画布
    UILabel * _titleLabel;//标题
    UILabel * _detailLabel;//详情
    
    UIButton * _OkButton;//确定按钮
    UIButton * _canleButton;//取消按钮
    
    CAShapeLayer * _pathLayer;//尝试保护内存
}
@end


@implementation WKAlertView



+ (instancetype)showAlertViewWithStyle:(WKAlertViewStyle)style title:(NSString *)title detail:(NSString *)detail canleButtonTitle:(NSString *)canle okButtonTitle:(NSString *)ok callBlock:(callBack)callBack
{
    switch (style) {
        case WKAlertViewStyleDefalut:
            [[self shared] drawRight];
            break;
        case WKAlertViewStyleSuccess:
            [[self shared] drawRight];

            break;
        case WKAlertViewStyleFail:
            [[self shared] drawWrong];

            break;
        case WKAlertViewStyleWaring:
            [[self shared] drawWaring];

            break;
        default:
            break;
    }
    [[self shared] addButtonTitleWithCancle:canle OK:ok];
    [[self shared] addTitle:title detail:detail];
    [[self shared] setClickBlock:nil];//释放掉之前的Block
    [[self shared] setClickBlock:callBack];
    [[self shared] setHidden:NO];//设置为不隐藏
    return  [self shared];
    
}

+ (instancetype)showAlertViewWithTitle:(NSString *)title detail:(NSString *)detail canleButtonTitle:(NSString *)canle okButtonTitle:(NSString *)ok callBlock:(callBack)callBack
{
  return [self showAlertViewWithStyle:WKAlertViewStyleSuccess title:title detail:detail canleButtonTitle:canle okButtonTitle:ok callBlock:callBack];
}
//单例
+ (instancetype)shared
{
    static dispatch_once_t once = 0;
    static WKAlertView *alert;
    dispatch_once(&once, ^{
        alert = [[WKAlertView alloc] init];
    });
    return alert;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = (CGRect) {{0.f,0.f}, [[UIScreen mainScreen] bounds].size};
        self.alpha = 1;
        [self setBackgroundColor:[UIColor clearColor]];
        self.hidden = NO;//不隐藏
        self.windowLevel = 100;
        
        [self setInterFace];
    }
    
    return self;
}
/**
 *  @author by wangkun, 15-03-11 17:03:18
 *
 *  界面初始化
 */
- (void)setInterFace
{
    [self logoInit];
    [self controlsInit];
}
/**
 *  @Author wang kun
 *
 *  初始化控件
 */
- (void)controlsInit
{
    
    CGFloat x = _logoView.frame.origin.x;
    CGFloat y = _logoView.frame.origin.y;
    CGFloat height = _logoView.frame.size.height;
    CGFloat width = _logoView.frame.size.width;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x ,y + height / 2, width, Title_Font + 5)];
    [_titleLabel setFont:[UIFont systemFontOfSize:Title_Font]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];

    _detailLabel  = [[UILabel alloc] initWithFrame:CGRectMake(x ,y + height / 2 + (Title_Font + 10), width, Detial_Font + 5)];
    _detailLabel.textColor = [UIColor grayColor];
    [_detailLabel setFont:[UIFont systemFontOfSize:Detial_Font]];
    [_detailLabel setTextAlignment:NSTextAlignmentCenter];

    CGFloat centerY = _detailLabel.center.y + 28;
    
    _OkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _OkButton.layer.cornerRadius = 5;
    _OkButton.titleLabel.font = [UIFont systemFontOfSize:Button_Font];
    _OkButton.center = CGPointMake(_detailLabel.center.x + 50, centerY);
    _OkButton.bounds = CGRectMake(0, 0, Button_Size_Width, Button_Size_Height);
    _OkButton.backgroundColor = OKBUTTON_BGCOLOR;

    
    _canleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _canleButton.center = CGPointMake(_detailLabel.center.x - 50+10, centerY);
    _canleButton.bounds = CGRectMake(0, 0, Button_Size_Width, Button_Size_Height);
    _canleButton.backgroundColor = CANCELBUTTON_BGCOLOR;
    _canleButton.layer.cornerRadius = 5;
    _canleButton.titleLabel.font = [UIFont systemFontOfSize:Button_Font];
    

    [self addSubview:_titleLabel];
    [self addSubview:_detailLabel];
    [self addSubview:_OkButton];
    [self addSubview:_canleButton];

    _canleButton.hidden = YES;
    _OkButton.hidden = YES;
    
    _OkButton.tag = TAG;
    _canleButton.tag = TAG + 1;
    
    [_OkButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_canleButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

}

/**
 *  @Author wang kun
 *
 *  初始化logo视图——画布
 */
#warning 需完善画布的清除，不适用移除，新建的办法
- (void)logoInit
{
    //移除画布
    [_logoView removeFromSuperview];
    _logoView = nil;
    //新建画布
    _logoView                     = [UIView new];
    _logoView.center              = CGPointMake(self.center.x, self.center.y - 40);
    _logoView.bounds              = CGRectMake(0, 0, 320 / 2, 320 / 2);
    _logoView.backgroundColor     = [UIColor whiteColor];
    _logoView.layer.cornerRadius  = 10;
    _logoView.layer.shadowColor   = [UIColor blackColor].CGColor;
    _logoView.layer.shadowOffset  = CGSizeMake(0, 5);
    _logoView.layer.shadowOpacity = 0.3f;
    _logoView.layer.shadowRadius  = 10.0f;
    
    //保证画布位于所有视图层级的最下方
    if (_titleLabel != nil) {
        [self insertSubview:_logoView belowSubview:_titleLabel];
    }
    else
    [self addSubview:_logoView];
}
/**
 *  @author by wangkun, 15-03-11 17:03:53
 *
 *  添加按钮
 *
 *  @param cancle 按钮标题
 *  @param ok     按钮标题
 */
- (void) addButtonTitleWithCancle:(NSString *)cancle OK:(NSString *)ok
{
    BOOL flag = NO;
    if (cancle == nil && ok != nil ) {
        flag = YES;
    }
    
    CGFloat centerY = _detailLabel.center.y + 28;
    

    if (flag) {
        _OkButton.center = CGPointMake(_detailLabel.center.x, centerY);
        _OkButton.bounds = CGRectMake(0, 0, Button_Size_Width, Button_Size_Height);
        _canleButton.hidden = YES;
        
    }
    else
    {
        _canleButton.hidden = NO;
        [_canleButton setTitle:cancle forState:UIControlStateNormal];
        _OkButton.center = CGPointMake(_detailLabel.center.x + 40, centerY);
        _OkButton.bounds = CGRectMake(0, 0, Button_Size_Width, Button_Size_Height);
    }
    _OkButton.hidden = NO;
    [_OkButton setTitle:ok forState:UIControlStateNormal];



}
/**
 *  @author by wangkun, 15-03-11 17:03:30
 *
 *  添加标题信息和详细信息
 *
 *  @param title  标题内容
 *  @param detail 详细内容
 */
- (void)addTitle:(NSString *)title detail:(NSString *)detail
{
    
    _titleLabel.text  = title;
    _detailLabel.text = detail;

}




/**
 *  @author by wangkun, 15-03-11 17:03:16
 *
 *  画圆和勾
 */
-(void) drawRight
{
    
    [self logoInit];
    //自绘制图标中心点
    CGPoint pathCenter = CGPointMake(_logoView.frame.size.width/2, _logoView.frame.size.height/2 - 40);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pathCenter radius:Logo_Size startAngle:0 endAngle:M_PI*2 clockwise:YES];

    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    
    
    CGFloat x = _logoView.frame.size.width/2.5 + 5;
    CGFloat y = _logoView.frame.size.height/2 - 45;
    //勾的起点
    [path moveToPoint:CGPointMake(x-5, y+3)];
    //勾的最底端
    CGPoint p1 = CGPointMake(x+10, y+19);
    [path addLineToPoint:p1];
    //勾的最上端
    CGPoint p2 = CGPointMake(x+35-5,y-25+15);
    [path addLineToPoint:p2];
    //新建图层——绘制上面的圆圈和勾
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor greenColor].CGColor;
    layer.lineWidth = 3.5;
    layer.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [_logoView.layer addSublayer:layer];

}

/**
 *  @Author wang kun
 *
 *  画三角形以及感叹号
 */
-(void) drawWaring
{
    
//    [_logoView removeFromSuperview];
    [self logoInit];
    //自绘制图标中心店
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;

    //绘制三角形
    CGFloat x = _logoView.frame.size.width/2;
    CGFloat y = 15;
    //三角形起点（上方）
    [path moveToPoint:CGPointMake(x, y)];
    //左边
    CGPoint p1 = CGPointMake(x - 45+10, y + 80-20);
    [path addLineToPoint:p1];
    //右边
    CGPoint p2 = CGPointMake(x + 45-10,y + 80-20);
    [path addLineToPoint:p2];
    //关闭路径
    [path closePath];

    //绘制感叹号
    //绘制直线
    [path moveToPoint:CGPointMake(x, y + 20)];
    CGPoint p4 = CGPointMake(x, y + 43);
    [path addLineToPoint:p4];
    //绘制实心圆
    [path moveToPoint:CGPointMake(x, y + 50)];
    [path addArcWithCenter:CGPointMake(x, y + 50) radius:2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    
    
    //新建图层——绘制上述路径
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor orangeColor].CGColor;
    layer.lineWidth = 3.5;
    layer.path = path.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [_logoView.layer addSublayer:layer];
}

/**
 *  @Author wang kun
 *
 *  画圆角矩形和叉
 */
- (void)drawWrong
{
  
    [self logoInit];
    
    
    CGFloat x = _logoView.frame.size.width / 2 - Logo_Size;
    CGFloat y = 15;
    
    //圆角矩形
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(x, y, Logo_Size * 2, Logo_Size * 2) cornerRadius:5];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineCapRound;
    
    CGFloat space = 20;
    //斜线1
    [path moveToPoint:CGPointMake(x + space, y + space)];
    CGPoint p1 = CGPointMake(x + Logo_Size * 2 - space, y + Logo_Size * 2 - space);
    [path addLineToPoint:p1];
    //斜线2
    [path moveToPoint:CGPointMake(x + Logo_Size * 2 - space , y + space)];
    CGPoint p2 = CGPointMake(x + space, y + Logo_Size * 2 - space);
    [path addLineToPoint:p2];
    
    //新建图层——绘制上述路径
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.lineWidth = 3.5;
    layer.path = path.CGPath;
#warning 使用NSStringFromSelector(@selector(strokeEnd))作为KeyPath的作用，绘制动画每一次Show均重复运行
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 0.5;
    //和上对应
    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    [_logoView.layer addSublayer:layer];
}

/**
 *  @author by wangkun, 15-03-11 17:03:29
 *
 *  按钮点击事件
 *
 *  @param sender 按钮
 */
- (void)buttonClick:(UIButton *)sender
{
    self.clickBlock(sender.tag - TAG);
}


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com