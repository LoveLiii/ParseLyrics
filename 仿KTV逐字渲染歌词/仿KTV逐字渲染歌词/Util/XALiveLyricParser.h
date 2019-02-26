//
//  XALiveLyricParse.h
//  XASDK
//
//  Created by XV~ on 2018/12/21.
//  Copyright © 2018 珠海云迈网络科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XALiveLyricParser : NSObject

//获取歌曲开始唱的时间
+ (NSInteger)startTimeWithLyric:(NSString *)lineLyric;

//根据每行歌词得到相应行的给个字的时间点数组
+ (NSMutableArray *)timeArrayWithLineLyric:(NSString *)lineLyric;

//得到每一行开始时间的数组
+ (NSMutableArray *)startTimeArrayWithLineLyric:(NSString *)lineLyric;

//得到每行的持续时间的数组
+ (NSMutableArray *)lineDurationArrayWithLineLyric:(NSString *)lineLyric;

//得到每行的持续时间
+ (NSInteger)getLineDuration:(NSString *)lyric;

//得到不带时间的歌词
+ (NSMutableString *)getLyricStringWithLyric:(NSString *)lineLyric;

//得到歌词的总行
+ (int)getLyricLineNumWithLyric:(NSString *)lineLyric;

//得到不带时间的歌词的数组
+ (NSMutableArray *)getLyricSArrayWithLyric:(NSString *)lineLyric;

//得到每行歌词有多少个字的数组
+ (NSMutableArray *)getLineLyricWordNmuWithLyric:(NSString *)lineLyric;

@end

NS_ASSUME_NONNULL_END
