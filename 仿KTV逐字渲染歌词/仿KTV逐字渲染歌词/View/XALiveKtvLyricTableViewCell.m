//
//  XALiveKtvLyricTableViewCell.m
//  XASDK
//
//  Created by XV~ on 2018/12/21.
//  Copyright © 2018 珠海云迈网络科技有限公司. All rights reserved.
//

#import "XALiveKtvLyricTableViewCell.h"
#import "Masonry.h"

#define RGB(rgbValue, a) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00) >> 8))/255.0 blue:((float)((rgbValue) & 0xFF))/255.0 alpha:a]

@implementation XALiveKtvLyricTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self buildUI];
    }
    return self;
}

#pragma mark - Private Method
- (void)buildUI {
    
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.lyricLabel];
    [self addSubview:self.maskLabel];
    
    [self.lyricLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    [self.maskLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self setupDefault];
}

- (void)setupDefault {
    self.lyricLabel.textColor = RGB(0xffffff, 0.6);
    self.maskLabel.textColor = RGB(0xF0D500, 1);
    self.maskLabel.backgroundColor = [UIColor clearColor];
    
    CALayer *maskLayer = [CALayer layer];
    maskLayer.anchorPoint = CGPointZero;//注意，按默认的anchorPoint，width动画是同时像左右扩展的
    
    //每次变色的位置
    maskLayer.position = CGPointMake(0,0);
    maskLayer.bounds = CGRectMake(0, 0, 0, 30);
    maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.maskLabel.layer.mask = maskLayer;
    self.maskLayer = maskLayer;
}

- (void)startLyricsAnimationWithTimeArray:(NSArray *)timeArray andLocationArray:(NSArray *)locationArray
{
    if (timeArray.count == 0) {
        [self removeLyricsAnimation];
    } else {
        //每行歌词的时间总长
        CGFloat totalDuration = [timeArray.lastObject floatValue]*1.0/1000;
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"bounds.size.width"];
        NSMutableArray *keyTimeArray = [NSMutableArray array];
        NSMutableArray *widthArray = [NSMutableArray array];
        for (int i = 0 ; i < timeArray.count; i++) {
            CGFloat tempTime = [timeArray[i] floatValue]*1.0/1000/totalDuration;
            [keyTimeArray addObject:@(tempTime)];
            CGFloat tempWidth = [locationArray[i] floatValue] * CGRectGetWidth(self.maskLabel.frame);
            [widthArray addObject:@(tempWidth)];
        }
        animation.values = widthArray;
        animation.keyTimes = keyTimeArray;
        animation.duration = totalDuration;
        animation.calculationMode = kCAAnimationLinear;
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [self.maskLayer addAnimation:animation forKey:@"MaskAnimation"];
    }
    
}

- (void)removeLyricsAnimation
{
    [self.maskLayer removeAllAnimations];
}

#pragma mark - Setters & Getters
- (void)setLyric:(NSString *)lyric
{
    _lyric = lyric;
    self.lyricLabel.text = lyric;
    self.maskLabel.text = lyric;
}

- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize;
    self.lyricLabel.font = [UIFont systemFontOfSize:fontSize];
    self.maskLabel.font = [UIFont systemFontOfSize:fontSize];
    if (fontSize == 20) {
        self.lyricLabel.textColor = [UIColor whiteColor];
    } else {
        self.lyricLabel.textColor = RGB(0xffffff, 0.6);
    }
    [self layoutIfNeeded];
}

- (UILabel *)lyricLabel {
    if (!_lyricLabel) {
        _lyricLabel = [[UILabel alloc] init];
        _lyricLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _lyricLabel.textAlignment = NSTextAlignmentCenter;
        _lyricLabel.shadowColor = RGB(0x000000, 0.5);
        _lyricLabel.shadowOffset = CGSizeMake(0, 1);
    }
    return _lyricLabel;
}

- (UILabel *)maskLabel {
    if (!_maskLabel) {
        _maskLabel = [[UILabel alloc] init];
        _maskLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _maskLabel.textAlignment = NSTextAlignmentCenter;
        _maskLabel.shadowColor = RGB(0x000000, 0.5);
        _maskLabel.shadowOffset = CGSizeMake(0, 1);
    }
    return _maskLabel;
}

@end
