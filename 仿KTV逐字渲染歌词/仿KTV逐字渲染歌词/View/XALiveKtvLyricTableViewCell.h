//
//  XALiveKtvLyricTableViewCell.h
//  XASDK
//
//  Created by XV~ on 2018/12/21.
//  Copyright © 2018 珠海云迈网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XALiveKtvLyricTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *lyric;
@property (nonatomic, strong) UILabel *lyricLabel;
@property (nonatomic, strong) UILabel *maskLabel;
@property (nonatomic, strong) CALayer *maskLayer;//用来控制maskLabel渲染的layer
@property (nonatomic, assign) CGFloat fontSize;

/**
 *  根据设置显示动画
 *
 *  @param timeArray     数组的内容是各个时间点，第一个必须是0，最后一个必须是总时间
 *  @param locationArray 对应各个时间点的位置，值从0~1，第一个必须是0，最后一个必须是1
 */
- (void)startLyricsAnimationWithTimeArray:(NSArray *)timeArray andLocationArray:(NSArray *)locationArray;

@end

NS_ASSUME_NONNULL_END
