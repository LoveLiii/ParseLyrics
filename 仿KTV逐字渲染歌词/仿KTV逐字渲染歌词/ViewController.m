//
//  ViewController.m
//  仿KTV逐字渲染歌词
//
//  Created by XV~ on 2019/2/26.
//  Copyright © 2019 Lemon. All rights reserved.
//

#import "ViewController.h"
#import "XALiveKtvLyricView.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) XALiveKtvLyricView *lyricView;// 歌词视图
@property (nonatomic, strong) CADisplayLink *displayLink;// 定时器
@property (nonatomic, copy) NSString *lyrics;
@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIImageView * imageView = [[UIImageView alloc]init];
    imageView.frame = self.view.frame;
    [imageView setImage:[UIImage imageNamed:@"bg_kge"]];
    [self.view addSubview:imageView];
    
    //拿到歌词
    NSString *path = [[NSBundle mainBundle] pathForResource:@"擁抱" ofType:@"lrc"];
    self.lyrics = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    //播放歌
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"擁抱" withExtension:@"mp3"];
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    self.player.delegate = self;
    [self.player prepareToPlay];
    
    //创建歌词视图
    [self creatLyricView];
    //创建播放按钮
    [self createPlayBtn];
}

- (void)creatLyricView
{
    self.lyricView = [[XALiveKtvLyricView alloc] init];
    [self.view addSubview:self.lyricView];
    self.lyricView.frame = CGRectMake(0, 200, kScreenWidth, 210);
    [self.lyricView clear];
    self.lyricView.lyrics = self.lyrics;
    
}

- (void)createPlayBtn
{
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.layer.masksToBounds = YES;
    self.playBtn.layer.cornerRadius = 30;
    [self.view addSubview:self.playBtn];
    self.playBtn.frame = CGRectMake(kScreenWidth/2-30,kScreenHeight-60 - 100, 60, 60);
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.playBtn.selected = NO;
    [self.playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [self.playBtn setTitle:@"停止" forState:UIControlStateSelected];
    self.playBtn.backgroundColor = [UIColor orangeColor];
}

- (void)playBtnClick:(UIButton *)btn
{
    if (btn.selected == NO) {
        [self.player play];
        //设置监控 每隔1帧刷新一次
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeTime)];
        self.displayLink.preferredFramesPerSecond = 1;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.lyricView.lyrics = self.lyrics;
        
        btn.selected = YES;
    }else{
        btn.selected = NO;
        [self.player stop];
    }
    
}

//判断换行
- (void)changeTime
{
    NSInteger time = self.player.currentTime * 1000;
    [self.lyricView updateTime:time];
}

#pragma mark - AVAudioPlayerDelegate
//播放结束的时候会被调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"播放结束");
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self.lyricView clear];
    self.playBtn.selected = !self.playBtn.selected;
}

@end
