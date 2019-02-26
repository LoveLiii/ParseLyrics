//
//  XALiveKtvLyricView.h
//  XASDK
//
//  Created by XV~ on 2018/12/21.
//  Copyright © 2018 珠海云迈网络科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XALiveKtvLyricView : UIView

@property (nonatomic, copy) NSString *lyrics;

@property (nonatomic, assign) NSInteger currentTime;

- (void)updateTime:(NSInteger)time;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
