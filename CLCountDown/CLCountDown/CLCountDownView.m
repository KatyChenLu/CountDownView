//
//  CLCountDownView.m
//  HiMaster3
//
//  Created by ChenLu on 2017/5/12.
//  Copyright © 2017年 chenlu. All rights reserved.
//

#import "CLCountDownView.h"


@interface CLCountDownView()
//显示天
@property (nonatomic) UILabel *dayLabel;
//显示小时
@property (nonatomic) UILabel *hourLabel;
// 显示分钟
@property (nonatomic) UILabel *minuteLabel;
// 显示秒
@property (nonatomic) UILabel *secondLabel;

// 显示时间的冒号集合， 可以更改这个集合内冒号的颜色， 字体等
@property (nonatomic) NSArray *colonsArray;

@property (nonatomic) NSTimer *timer;
// 用于展示的秒， 分钟， 小时
@property (nonatomic, assign) int day;
@property (nonatomic, assign) int hour;
@property (nonatomic, assign) int minute;
@property (nonatomic, assign) int second;

@property (nonatomic, assign) BOOL didRegisterNotificaton;

// 进入后台时since 1970的秒数
@property (nonatomic, assign) NSTimeInterval endBackgroundTimeInterval;
// 当前倒计时剩余秒数
@property (nonatomic, assign) NSTimeInterval countDownLeftTimeInterval;


// 设置小时重新设置label的frame，小时默认两位数，可能超过两位数
- (void)setDayText:(NSString *)hour;



@end

@implementation CLCountDownView

+ (instancetype)allocCountDownWithTimeInterval:(NSTimeInterval)countDownTimeInterval themeColor:(UIColor *)themeColor textFont:(UIFont *)textFont colonColor:(UIColor *)colonColor countDownType:(CountDownType)countDownType {
    CLCountDownView * view = [[CLCountDownView alloc] initWithFrame:CGRectZero];
    view.countDownTimeInterval = countDownTimeInterval;
    view.themeColor = themeColor;
    view.textFont = textFont;
    view.colonColor = colonColor;
    view.countDownType = countDownType;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeValues];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeValues];
    }
    return self;
}

- (void)initializeValues
{
    _themeColor = [UIColor redColor];
    _colonColor = [UIColor darkTextColor];
    _textColor = [UIColor darkTextColor];
    _textFont = [UIFont systemFontOfSize:14.0];
    _recoderTimeIntervalDidInBackground = NO;
    _didRegisterNotificaton = NO;
    _countDownType = CountDownUseChar;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self adjustSubViewsWithFrame:frame];
}

- (void)setRecoderTimeIntervalDidInBackground:(BOOL)recoderTimeIntervalDidInBackground
{
    _recoderTimeIntervalDidInBackground = recoderTimeIntervalDidInBackground;
    if (recoderTimeIntervalDidInBackground)
    {
        [self observeNotification];
    }
    
    if (!recoderTimeIntervalDidInBackground && _didRegisterNotificaton)
    {
        [self removeObservers];
    }
}

/**
 *  调整时分秒的frame
 *
 */
- (void)adjustSubViewsWithFrame:(CGRect)frame
{
    if (!self.dayLabel.superview)
    {
        [self addSubview:self.dayLabel];
    }
    
    if (!self.hourLabel.superview)
    {
        [self addSubview:self.hourLabel];
    }
    
    if (!self.minuteLabel.superview)
    {
        [self addSubview:self.minuteLabel];
    }
    
    if (!self.secondLabel.superview)
    {
        [self addSubview:self.secondLabel];
    }
    
    [_dayLabel sizeToFit];
    CGFloat dayLabelWidth = _dayLabel.frame.size.width;
    CGFloat width = frame.size.width;
    CGFloat colonWidth = 23;
    CGFloat itemWidth = (width - colonWidth * 4) / 4;
    if (dayLabelWidth < itemWidth)
    {
        dayLabelWidth = itemWidth;
    }
    itemWidth = (width - dayLabelWidth - colonWidth * 4) / 3;
    CGFloat itemHeight = frame.size.height;
    
    // 如果存在colon view的话先将colon view 移除当前视图
    if (_colonsArray.count > 0)
    {
        for (UIView *subView in _colonsArray)
        {
            [subView removeFromSuperview];
        }
    }
    
    
    UILabel *colon0 = [[UILabel alloc] initWithFrame:CGRectMake(dayLabelWidth, 0, colonWidth, itemHeight)];
    colon0.text = (_countDownType == CountDownUseChar)? @"天" : @":";
    colon0.backgroundColor = [UIColor clearColor];
    colon0.textColor = _colonColor;
    colon0.font = _textFont;
    colon0.textAlignment = NSTextAlignmentCenter;
    [self addSubview:colon0];
    
    UILabel *colonOne = [[UILabel alloc] initWithFrame:CGRectMake(dayLabelWidth + itemWidth + colonWidth, 0, colonWidth, itemHeight)];
    colonOne.text = _countDownType == CountDownUseChar? @"时" : @":";
    colonOne.backgroundColor = [UIColor clearColor];
    colonOne.textColor = _colonColor;
    colonOne.font = _textFont;
    colonOne.textAlignment = NSTextAlignmentCenter;
    [self addSubview:colonOne];
    
    UILabel *colonTwo = [[UILabel alloc] initWithFrame:CGRectMake(dayLabelWidth + 2*itemWidth + 2*colonWidth, 0, colonWidth, itemHeight)];
    colonTwo.text =  _countDownType == CountDownUseChar? @"分" : @":";
    colonTwo.backgroundColor = [UIColor clearColor];
    colonTwo.textColor = _colonColor;
    colonTwo.font = _textFont;
    colonTwo.textAlignment = NSTextAlignmentCenter;
    [self addSubview:colonTwo];
    
    
    UILabel *colonThird = [[UILabel alloc] initWithFrame:CGRectMake(dayLabelWidth + 3*itemWidth + 3*colonWidth, 0, colonWidth, itemHeight)];
    colonThird.text =   @"秒" ;
    colonThird.backgroundColor = [UIColor clearColor];
    colonThird.textColor = _colonColor;
    colonThird.font = _textFont;
    colonThird.textAlignment = NSTextAlignmentCenter;
    
    if (_countDownType == CountDownUseChar) {
        [self addSubview:colonThird];
        _colonsArray = @[colon0,colonOne,colonTwo,colonThird];

    }else{
        _colonsArray = @[colon0,colonOne,colonTwo,colonThird];

    }
    
    colon0 = nil;
    colonOne = nil;
    colonTwo = nil;
    colonThird = nil;
    
    _dayLabel.frame = CGRectMake(0, 0, dayLabelWidth, itemHeight);
    _hourLabel.frame = CGRectMake(CGRectGetMaxX(_dayLabel.frame) + colonWidth, 0, itemWidth, itemHeight);
    _minuteLabel.frame = CGRectMake(CGRectGetMaxX(_hourLabel.frame) + colonWidth, 0, itemWidth, itemHeight);
    _secondLabel.frame = CGRectMake(CGRectGetMaxX(_minuteLabel.frame) + colonWidth, 0, itemWidth, itemHeight);
}

- (void)setDayText:(NSString *)day
{
    NSInteger texeLength = _dayLabel.text.length;
    _dayLabel.text = day;
    if (texeLength != _dayLabel.text.length)
    {
        [self adjustSubViewsWithFrame:self.frame];
    }
}

#pragma mark init subviews
- (UILabel *)dayLabel
{
    if (!_dayLabel)
    {
        _dayLabel = [UILabel new];
        _dayLabel.textAlignment = NSTextAlignmentCenter;
        _dayLabel.backgroundColor = _themeColor;
        _dayLabel.textColor = _textColor;
        _dayLabel.font = _textFont;
        _dayLabel.layer.cornerRadius = 4;
        _dayLabel.clipsToBounds = YES;
        _dayLabel.text = @"00";
    }
    return _dayLabel;
}

- (UILabel *)hourLabel
{
    if (!_hourLabel)
    {
        _hourLabel = [UILabel new];
        _hourLabel.textAlignment = NSTextAlignmentCenter;
        _hourLabel.backgroundColor = _themeColor;
        _hourLabel.textColor = _textColor;
        _hourLabel.font = _textFont;
        _hourLabel.layer.cornerRadius = 4;
        _hourLabel.clipsToBounds = YES;
        _hourLabel.text = @"00";
    }
    return _hourLabel;
}

- (UILabel *)minuteLabel
{
    if (!_minuteLabel)
    {
        _minuteLabel = [UILabel new];
        _minuteLabel.textAlignment = NSTextAlignmentCenter;
        _minuteLabel.backgroundColor = _themeColor;
        _minuteLabel.textColor = _textColor;
        _minuteLabel.font = _textFont;
        _minuteLabel.layer.cornerRadius = 4;
        _minuteLabel.clipsToBounds = YES;
        _minuteLabel.text = @"00";
    }
    return _minuteLabel;
}

- (UILabel *)secondLabel
{
    if (!_secondLabel)
    {
        _secondLabel = [UILabel new];
        _secondLabel.textAlignment = NSTextAlignmentCenter;
        _secondLabel.backgroundColor = _themeColor;
        _secondLabel.textColor = _textColor;
        _secondLabel.font = _textFont;
        _secondLabel.layer.cornerRadius = 4;
        _secondLabel.clipsToBounds = YES;
        _secondLabel.text = @"00";
    }
    return _secondLabel;
}

#pragma mark set property value
- (void)setThemeColor:(UIColor *)themeColor
{
    if (_themeColor != themeColor)
    {
        _themeColor = themeColor;
        _minuteLabel.backgroundColor = themeColor;
        _secondLabel.backgroundColor = themeColor;
        _hourLabel.backgroundColor = themeColor;
        _dayLabel.backgroundColor = themeColor;
    }
}

- (void)setTextColor:(UIColor *)textColor
{
    if (_textColor != textColor)
    {
        _textColor = textColor;
        _minuteLabel.textColor = textColor;
        _secondLabel.textColor = textColor;
        _hourLabel.textColor = textColor;
        _dayLabel.textColor = textColor;
    }
}

- (void)setTextFont:(UIFont *)textFont
{
    if (_textFont != textFont)
    {
        _textFont = textFont;
        _secondLabel.font = textFont;
        _minuteLabel.font = textFont;
        _hourLabel.font = textFont;
        _dayLabel.font = textFont;
        if (_colonsArray.count > 0)
        {
            for (UILabel *label in _colonsArray)
            {
                label.font = textFont;
            }
        }
    }
}

- (void)setColonColor:(UIColor *)colonColor
{
    if (_colonColor != colonColor)
    {
        _colonColor = colonColor;
        if (_colonsArray.count > 0)
        {
            for (UILabel *label in _colonsArray)
            {
                label.textColor = colonColor;
            }
        }
    }
}
- (void)setCountDownType:(CountDownType)countDownType {
   
        _countDownType = countDownType;
    
}

- (void)setCountDownTimeInterval:(NSTimeInterval)countDownTimeInterval
{
    _countDownTimeInterval = countDownTimeInterval;
    if (_countDownTimeInterval < 0)
    {
        _countDownTimeInterval = 0;
    }
    _day = (int)_countDownTimeInterval / (24*60*60) ;
    _hour = (int)(_countDownTimeInterval/(60*60) - _day * 24);
    
    _minute = (int)(_countDownTimeInterval/60 - _hour*60 - _day * 24 * 60);
    _second = (int)(_countDownTimeInterval-_minute*60-_hour*60*60 - _day * 24 * 60 * 60);
    
    
    [self setDayText:[NSString stringWithFormat:@"%02d", _day]];
    _hourLabel.text = [NSString stringWithFormat:@"%02d", _hour];
    _minuteLabel.text = [NSString stringWithFormat:@"%02d", _minute];
    _secondLabel.text = [NSString stringWithFormat:@"%02d", _second];
    if (_countDownTimeInterval > 0 && !_timer)
    {
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        //        [self.timer fire];
    }
}

- (NSTimer *)timer
{
    if (!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(adjustCoundDownTimer:) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)adjustCoundDownTimer:(NSTimer *)timer
{
    _countDownTimeInterval --;
    
    if (_hour == 0 && _day >0) {
        _day -= 1;
        _hour = 24;
        
        
        [self setDayText:[NSString stringWithFormat:@"%02d", _day]];
    }
    
    if (_minute == 0 && _hour > 0)
    {
        _minute = 60;
        if (_hour > 0) {
            _hour -= 1;
            _hourLabel.text = [NSString stringWithFormat:@"%02d", _hour];
            
        }
        
    }
    
    if (_second == 0 && _minute > 0)
    {
        _second = 60;
        if (_minute > 0)
        {
            _minute -= 1;
            _minuteLabel.text = [NSString stringWithFormat:@"%02d", _minute];
        }
    }
    
    if (_second > 0)
    {
        _second -= 1;
        _secondLabel.text = [NSString stringWithFormat:@"%02d", _second];
    }
    
    if (_second <= 0 && _minute <= 0 && _hour <= 0 && _day <= 0)
    {
        [_timer invalidate];
        _timer = nil;
        if (_delegate && [_delegate respondsToSelector:@selector(countDownDidFinished)]) {
            [_delegate countDownDidFinished];
        }
    }
}

- (void)stopCountDown
{
    [self removeObservers];
    [_timer invalidate];
    _timer = nil;
}

#pragma mark Observers and methods

- (void)observeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    _didRegisterNotificaton = YES;
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _didRegisterNotificaton = NO;
}

- (void)didInBackground:(NSNotification *)notification
{
    _endBackgroundTimeInterval = [[NSDate date] timeIntervalSince1970];
    _countDownLeftTimeInterval = _countDownTimeInterval;
}

- (void)willEnterForground:(NSNotification *)notification
{
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval diff = currentTimeInterval - _endBackgroundTimeInterval;
    [self setCountDownTimeInterval:_countDownLeftTimeInterval - diff];
}

- (void)dealloc
{
    [self removeObservers];
    _textColor = nil;
    _textFont = nil;
    _themeColor = nil;
    _textFont = nil;
    _colonsArray = nil;
    _dayLabel = nil;
    _hourLabel = nil;
    _minuteLabel = nil;
    _secondLabel = nil;
}

@end
