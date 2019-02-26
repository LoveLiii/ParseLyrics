//
//  XALiveLyricParse.m
//  XASDK
//
//  Created by XV~ on 2018/12/21.
//  Copyright © 2018 珠海云迈网络科技有限公司. All rights reserved.
//

#import "XALiveLyricParser.h"

@implementation XALiveLyricParser

+ (NSInteger)startTimeWithLyric:(NSString *)lineLyric
{
    if (![self lyricCheck:lineLyric]) {
        return 0;
    }
    
    NSArray *array;
    if ([lineLyric rangeOfString:@"\r"].location != NSNotFound) {
        array = [lineLyric componentsSeparatedByString:@"\r"];
    }else{
        array = [lineLyric componentsSeparatedByString:@"\n"];
    }
    
    for (int i = 0; i<array.count; i++) {
        //截取每行的开始时间
        NSRange start = [array[i] rangeOfString:@"["];
        NSRange bracket = [array[i] rangeOfString:@"<"];
        
        if (start.location != NSNotFound && bracket.location != NSNotFound) {
            NSRange end = [array[i] rangeOfString:@","];
            NSString *sub = [array[i] substringWithRange:NSMakeRange(start.location+1, end.location-start.location-1)];
            return [sub integerValue];
        }
    }
    return 0;
}

//返回每句歌词的当个字time组成的数据
+ (NSMutableArray *)timeArrayWithLineLyric:(NSString *)lineLyric
{
    if (![self lyricCheck:lineLyric]) {
        return nil;
    }
    //把歌词每个单词的time的最后一个,0 去掉。
    NSString * lineLyricd= [lineLyric stringByReplacingOccurrencesOfString:@",0>" withString:@">"];
    //最后返回的时间数组，包含每一行数组的数组
    NSMutableArray * timeArray = [[NSMutableArray alloc]init];
    //    //单个句歌词的时间数组
    //    NSMutableArray * oneLineArray = [[NSMutableArray alloc]init];
    //把歌词按行分成数组
    NSArray *lineArray;
    if ([lineLyricd rangeOfString:@"\r"].location != NSNotFound) {
        lineArray = [lineLyricd componentsSeparatedByString:@"\r"];
    }else{
        lineArray = [lineLyricd componentsSeparatedByString:@"\n"];
    }
    for (int i=0; i<lineArray.count; i++) {
        //截取每行的开始时间
        NSRange lineStart = [lineArray[i] rangeOfString:@"["];
        NSRange bracket = [lineArray[i] rangeOfString:@"<"];
        
        if (lineStart.location != NSNotFound && bracket.location != NSNotFound) {
            //单个句歌词的时间数组
            NSMutableArray * oneLineArray = [[NSMutableArray alloc]init];
            [oneLineArray removeAllObjects];
            //截取总时间以后的字符串，因为我要返回每个字的时间数组
            
            NSRange start = [lineArray[i] rangeOfString:@"]"];
            if (start.location!=NSNotFound) {
                NSString *sub = [lineArray[i] substringFromIndex:start.location+1];
                //把sub按>分成数组
                NSArray * array = [sub componentsSeparatedByString:@">"];
                for (int y = 0; y<array.count-1; y++) {
                    //取出每个单词的开始时间
                    NSRange start = [array[y] rangeOfString:@"<"];
                    NSRange end = [array[y] rangeOfString:@","];
                    NSString *sub1 = [array[y] substringWithRange:NSMakeRange(start.location+1, end.location-start.location-1)];
                    [oneLineArray addObject:sub1];
                }
                
                //因为最后一个时间没取到，在这里拿到最后一个单词的延长时间加上最后一个单词的开始时间为最终时间，加到oneLineArray数组的后面
                NSRange start1 = [array[array.count-2] rangeOfString:@","];
                NSString *sub2 = [array[array.count-2] substringFromIndex:start1.location+1];
                NSString * lastTime = oneLineArray[oneLineArray.count-1];
                int sub2N = [sub2 intValue];
                int lastTimeN = [lastTime intValue];
                int lastN = sub2N + lastTimeN;
                NSString * lastStr = [NSString stringWithFormat:@"%d",lastN];
                [oneLineArray addObject:lastStr];
                [timeArray addObject:oneLineArray];
            }
        }
        
    }
    return timeArray;
}

//得到每一行开始时间的数组,可根据时间判断换行
+ (NSMutableArray *)startTimeArrayWithLineLyric:(NSString *)lineLyric
{
    if (![self lyricCheck:lineLyric]) {
        return nil;
    }
    NSMutableArray * stratTimeArray = [[NSMutableArray alloc]init];
    
    NSArray *array;
    if ([lineLyric rangeOfString:@"\r"].location != NSNotFound) {
        array = [lineLyric componentsSeparatedByString:@"\r"];
    }else{
        array = [lineLyric componentsSeparatedByString:@"\n"];
    }
    
    for (int i = 0; i<array.count; i++) {
        //截取每行的开始时间
        NSRange start = [array[i] rangeOfString:@"["];
        NSRange bracket = [array[i] rangeOfString:@"<"];
        
        if (start.location != NSNotFound && bracket.location != NSNotFound) {
            NSRange end = [array[i] rangeOfString:@","];
            NSString *sub = [array[i] substringWithRange:NSMakeRange(start.location+1, end.location-start.location-1)];
            [stratTimeArray addObject:sub];
        }
    }
    return stratTimeArray;
}

+ (NSMutableArray *)lineDurationArrayWithLineLyric:(NSString *)lineLyric
{
    if (![self lyricCheck:lineLyric]) {
        return nil;
    }
    NSMutableArray *lineDurationArray = [[NSMutableArray alloc]init];
    NSArray *array;
    if ([lineLyric rangeOfString:@"\r"].location != NSNotFound) {
        array = [lineLyric componentsSeparatedByString:@"\r"];
    }else{
        array = [lineLyric componentsSeparatedByString:@"\n"];
    }
    for (int i = 0; i<array.count; i++) {
        //截取每行的持续时间
        NSRange start = [array[i] rangeOfString:@"["];
        NSRange bracket = [array[i] rangeOfString:@"<"];
        if (start.location != NSNotFound && bracket.location != NSNotFound) {
            NSInteger duration = [self getLineDuration:array[i]];
            NSString *durationString = [NSString stringWithFormat:@"%zd", duration];
            [lineDurationArray addObject:durationString];
        }
    }
    return lineDurationArray;
}

+ (NSInteger)getLineDuration:(NSString *)lyric
{
    if (![self lyricCheck:lyric]) {
        return 0;
    }
    NSArray *wordArray = [lyric componentsSeparatedByString:@"<"];
    NSString *lastWord = wordArray.lastObject;
    NSArray *timeArray = [lastWord componentsSeparatedByString:@","];
    
    NSInteger duration = 0;
    if (timeArray.count >= 2) {
        NSInteger startTime = [[timeArray objectAtIndex:0] integerValue];
        NSInteger wordDuration = [[timeArray objectAtIndex:1] integerValue];
        duration = startTime + wordDuration;
    }
    
    return duration;
}
//得到不带时间的歌词
+ (NSMutableString *)getLyricStringWithLyric:(NSString *)lineLyric
{
    NSMutableString * LyricStr = [[NSMutableString alloc]init];
    
    NSArray *lineArray;
    if ([lineLyric rangeOfString:@"\r"].location != NSNotFound) {
        lineArray = [lineLyric componentsSeparatedByString:@"\r"];
    }else{
        lineArray = [lineLyric componentsSeparatedByString:@"\n"];
    }
    
    for (int i=0; i<lineArray.count; i++) {
        
        NSRange lineStart = [lineArray[i] rangeOfString:@"["];
        NSRange bracket = [lineArray[i] rangeOfString:@"<"];
        
        if (lineStart.location != NSNotFound && bracket.location != NSNotFound) {
            NSArray * array = [lineArray[i] componentsSeparatedByString:@"<"];
            NSString * lineStr = [NSString string];
            for (int y=1; y<array.count; y++) {
                NSRange start = [array[y] rangeOfString:@">"];
                NSString *sub1 = [array[y] substringFromIndex:start.location+1];
                lineStr = [lineStr stringByAppendingString:sub1];
            }
            
            [LyricStr appendString:lineStr];
            [LyricStr appendString:@"\n"];
            
        }
    }
    return LyricStr;
}

//得到不带时间的歌词的数组
+ (NSMutableArray *)getLyricSArrayWithLyric:(NSString *)lineLyric
{
    if (![self lyricCheck:lineLyric]) {
        return nil;
    }
    NSMutableArray * lyricSArray = [[NSMutableArray alloc]init];
    NSArray *lineArray;
    if ([lineLyric rangeOfString:@"\r"].location != NSNotFound) {
        lineArray = [lineLyric componentsSeparatedByString:@"\r"];
    }else{
        lineArray = [lineLyric componentsSeparatedByString:@"\n"];
    }
    
    for (int i=0; i<lineArray.count; i++) {
        
        NSRange lineStart = [lineArray[i] rangeOfString:@"["];
        NSRange bracket = [lineArray[i] rangeOfString:@"<"];
        
        if (lineStart.location != NSNotFound && bracket.location != NSNotFound) {
            NSArray * array = [lineArray[i] componentsSeparatedByString:@"<"];
            NSString * lineStr = [NSString string];
            for (int y=1; y<array.count; y++) {
                NSRange start = [array[y] rangeOfString:@">"];
                NSString *sub1 = [array[y] substringFromIndex:start.location+1];
                lineStr = [lineStr stringByAppendingString:sub1];
            }
            [lyricSArray addObject:lineStr];
        }
        
    }
    return lyricSArray;
}

//得到歌词的总行
+ (int)getLyricLineNumWithLyric:(NSString *)lineLyric
{
    if (![self lyricCheck:lineLyric]) {
        return 0;
    }
    int lineNum;
    NSArray *lineArray;
    if ([lineLyric rangeOfString:@"\r"].location != NSNotFound) {
        lineArray = [lineLyric componentsSeparatedByString:@"\r"];
    }else{
        lineArray = [lineLyric componentsSeparatedByString:@"\n"];
    }
    lineNum = (int)lineArray.count - 1;
    return lineNum;
}

//得到每行歌词有多少个字的数组
+ (NSMutableArray *)getLineLyricWordNmuWithLyric:(NSString *)lineLyric
{
    if (![self lyricCheck:lineLyric]) {
        return nil;
    }
    
    NSMutableArray * wordNumArray = [[NSMutableArray alloc]init];
    NSArray *lineArray;
    if ([lineLyric rangeOfString:@"\r"].location != NSNotFound) {
        lineArray = [lineLyric componentsSeparatedByString:@"\r"];
    }else{
        lineArray = [lineLyric componentsSeparatedByString:@"\n"];
    }
    for (int i=0; i<lineArray.count; i++) {
        
        NSRange lineStart = [lineArray[i] rangeOfString:@"["];
        NSRange bracket = [lineArray[i] rangeOfString:@"<"];
        
        if (lineStart.location != NSNotFound && bracket.location != NSNotFound) {
            NSArray * array = [lineArray[i] componentsSeparatedByString:@"<"];
            int num = (int)array.count-1;
            
            NSString * sNum = [NSString stringWithFormat:@"%d",num];
            [wordNumArray addObject:sNum];
            
        }
        
    }
    return wordNumArray;
}

+ (BOOL)lyricCheck:(NSString *)lyric
{
    if (lyric.length == 0 || lyric == nil) {
        return NO;
    }
    return YES;
}

@end
