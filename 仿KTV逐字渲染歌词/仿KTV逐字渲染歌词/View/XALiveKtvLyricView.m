//
//  XALiveKtvLyricView.m
//  XASDK
//
//  Created by XV~ on 2018/12/21.
//  Copyright © 2018 珠海云迈网络科技有限公司. All rights reserved.
//

#import "XALiveKtvLyricView.h"
#import "XALiveKtvLyricTableViewCell.h"
#import "XALiveLyricParser.h"
#import "Masonry.h"

@interface XALiveKtvLyricView ()<UITableViewDelegate, UITableViewDataSource>

//当前行
@property (nonatomic, assign) NSInteger currentRow;
//当前行的时间数组
@property (nonatomic, strong) NSArray *currentTimeArray;
//每行歌词的每个单词在相应时间对应的位置数组
@property (nonatomic, strong) NSArray *currentLocationArray;

//每行歌词的时间数组
@property (nonatomic, strong) NSMutableArray *timeArray;
//换行时间数组
@property (nonatomic, strong) NSMutableArray *startTimeArray;
//纯歌词
@property (nonatomic, strong) NSMutableString *lyricsStr;
//纯歌词数组
@property (nonatomic, strong) NSMutableArray *lyricsArray;
//每行歌词单词个数的数组
@property (nonatomic, strong) NSMutableArray *wordNumArray;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation XALiveKtvLyricView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
    }
    return self;
}

#pragma mark - Private Method
- (void)buildUI {
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)clear
{
    void(^block)(void) = ^{
        self.currentTime = 0;
        self.currentRow = -1;
        self.currentTimeArray = nil;
        self.currentLocationArray = nil;
        [self.lyricsStr setString:@""];
        [self.timeArray removeAllObjects];
        [self.startTimeArray removeAllObjects];
        [self.lyricsArray removeAllObjects];
        [self.wordNumArray removeAllObjects];
        [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
        [self.tableView reloadData];
    };
    if ([NSThread isMainThread]) {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

//根据播放时间换行
- (void)updateTime:(NSInteger)time
{
    if (_startTimeArray.count == 0) {
        return;
    }
    
    if (self.currentRow < _startTimeArray.count - 2 || self.currentRow == -1) {
        for (int i=0; i<_startTimeArray.count; i++) {
            int startTime = [_startTimeArray[i] intValue];
            if (time - startTime < 0) {
                [self changeRowWithNum:i-1];
                return;
            }
        }
    } else {
        int startTime = [_startTimeArray[_startTimeArray.count - 1] intValue];
        if (time > startTime) {
            [self changeRowWithNum:(int)_startTimeArray.count - 1];
            return;
        }
    }
    
}

//歌词换行
- (void)changeRowWithNum:(int)num
{

    if (self.currentRow == num || num < 0) {
        return;
    }
    NSLog(@"num - %d",num);
    //当前行每个词的时间点
    self.currentTimeArray = self.timeArray[num];
    //计算 locationArray每行歌词的每个单词在相应时间对应的位置，假设为1总长，在歌词Label里用比例乘宽度得到位置
    NSMutableArray * localArray =[[NSMutableArray alloc]init];
    NSInteger wordNum = [_wordNumArray[num] integerValue];
    for (int i=0; i<=wordNum; i++) {
        float n = i*1.0/wordNum;
        NSString * wordSNum = [NSString stringWithFormat:@"%lf",n];
        [localArray addObject:wordSNum];
    }
    self.currentLocationArray = localArray;
    self.currentRow = num;
    
    [self.tableView setContentOffset:CGPointMake(0,num*30) animated:YES];
    for (int i = 0; i <= self.lyricsArray.count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        XALiveKtvLyricTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (i == num) {
            cell.fontSize = 20;
            [cell startLyricsAnimationWithTimeArray:self.currentTimeArray andLocationArray:self.currentLocationArray];
        } else {
            cell.fontSize = 15;
            [cell startLyricsAnimationWithTimeArray:[NSArray array] andLocationArray:[NSArray array]];
        }
    }
}

//根据时间找到对应的行
- (NSInteger)getCurrentRow:(NSInteger)time
{
    NSInteger ret_index;                        /* 结果索引 */
    NSInteger mid_index;                        /* 中位游标 */
    NSInteger left_index;                       /* 左位游标 */
    NSInteger right_index;                      /* 右位游标 */
    float left_abs;                       /* 左位的值与目标值之间的差的绝对值 */
    float right_abs;                      /* 右位的值与目标值之间的差的绝对值 */
    
    ret_index = 0;
    left_index = 0;
    right_index = (int)[self.startTimeArray count] - 1;
    mid_index = 0;
    left_abs = 0;
    right_abs = 0;
    
    while(left_index != right_index){
        mid_index = (right_index + left_index) / 2;
        if (time <= [self.startTimeArray[mid_index] integerValue]) {
            right_index = mid_index;
        } else {
            left_index = mid_index;
        }
        if (right_index - left_index < 2) {
            break;
        }
    }
    
    left_abs = labs([self.startTimeArray[left_index] integerValue] - time);
    right_abs = labs([self.startTimeArray[right_index] integerValue] - time);
    ret_index = right_abs <= left_abs ? right_index : left_index;
    
    return ret_index;
    
}

//解析歌词
- (void)getLyricsInfoByLyrics:(NSString *)lyrics
{
    //得到每句的时间
    self.timeArray = [XALiveLyricParser timeArrayWithLineLyric:lyrics];
    //得到换行时间
    self.startTimeArray = [XALiveLyricParser startTimeArrayWithLineLyric:lyrics];
    //得到纯歌词
    self.lyricsStr = [XALiveLyricParser getLyricStringWithLyric:lyrics];
    //得到纯歌词数组
    self.lyricsArray = [XALiveLyricParser getLyricSArrayWithLyric:lyrics];
    //每行歌词单词个数的数组
    self.wordNumArray = [XALiveLyricParser getLineLyricWordNmuWithLyric:lyrics];
}

#pragma mark - UITableViewDelegate & UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.lyricsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XALiveKtvLyricTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"lyricTableViewCell"];
    cell.lyric = self.lyricsArray[indexPath.row];
    return cell;
}

#pragma makr - Setters & Getters
- (void)setLyrics:(NSString *)lyrics
{
    _lyrics = lyrics;
    
    NSInteger startTime = [XALiveLyricParser startTimeWithLyric:_lyrics];
    if (startTime > 4000) {
        startTime = startTime - 4000;
        NSString *firstStr;
        if ([_lyrics rangeOfString:@"\r"].location != NSNotFound) {
             firstStr = [NSString stringWithFormat:@"[%zd,4000]<0,1000,0>•<1000,1000,0>•<2000,1000,0>•<3000,1000,0>•\r\n",startTime];
        }else{
            firstStr = [NSString stringWithFormat:@"[%zd,4000]<0,1000,0>•<1000,1000,0>•<2000,1000,0>•<3000,1000,0>•\n",startTime];
        }
       
        _lyrics = [NSString stringWithFormat:@"%@%@",firstStr,_lyrics];
    }
    [self getLyricsInfoByLyrics:_lyrics];
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    XALiveKtvLyricTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.fontSize = 20;
    [cell startLyricsAnimationWithTimeArray:self.currentTimeArray andLocationArray:self.currentLocationArray];
}

- (void)setCurrentTime:(NSInteger)currentTime
{
    _currentTime = currentTime;
    if (self.startTimeArray.count > 0 && currentTime > 0) {
        NSInteger row = [self getCurrentRow:currentTime];
        if (row > 0) {
            [self changeRowWithNum:(int)row];
        }
    }
}

- (NSArray *)currentTimeArray
{
    if (!_currentTimeArray) {
        _currentTimeArray = [NSArray array];
    }
    return _currentTimeArray;
}

- (NSArray *)currentLocationArray
{
    if (!_currentLocationArray) {
        _currentLocationArray = [NSArray array];
    }
    return _currentLocationArray;
}

- (NSMutableArray *)timeArray
{
    if (!_timeArray) {
        _timeArray = [NSMutableArray array];
    }
    return _timeArray;
}
- (NSMutableArray *)startTimeArray
{
    if (!_startTimeArray) {
        _startTimeArray = [NSMutableArray array];
    }
    return _startTimeArray;
}
- (NSMutableString *)lyricsStr
{
    if (!_lyricsStr) {
        _lyricsStr = [NSMutableString string];
    }
    return _lyricsStr;
}
- (NSMutableArray *)lyricsArray
{
    if (!_lyricsArray) {
        _lyricsArray = [NSMutableArray array];
    }
    return _lyricsArray;
}
- (NSMutableArray *)wordNumArray
{
    if (!_wordNumArray) {
        _wordNumArray = [NSMutableArray array];
    }
    return _wordNumArray;
}

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[XALiveKtvLyricTableViewCell class] forCellReuseIdentifier:@"lyricTableViewCell"];
        _tableView.userInteractionEnabled = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.allowsSelection = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
    }
    return _tableView;
}

@end
