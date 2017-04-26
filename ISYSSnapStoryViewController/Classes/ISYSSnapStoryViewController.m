//
//  AAMStoryViewController.m
//  SnapchatStoryPlayer
//
//  Created by clines192 on 21/04/2017.
//  Copyright © 2017 iSystematic LLC. All rights reserved.
//

@import AVFoundation;
#import "ISYSSnapStoryViewController.h"

#import <SpinKit/RTSpinKitView.h>
#import <ISYSSnapStoryViewController/ISYSSnapStoryViewController-Swift.h>

@interface ISYSSnapStoryViewController ()

/// Array of urls which will be played
@property (nonatomic, strong) NSArray* videoUrls;

@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;

@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) SnapTimerView * timerView;
@property (nonatomic, weak) RTSpinKitView *spinner;
@property (nonatomic, assign) BOOL isLoading;

/// Array of AVPlayerItem
@property (nonatomic, strong) NSMutableArray * playerItems;

/// Currently playing AVPlayerItem
@property (nonatomic, assign) NSInteger currentItemIndex;

@property (nonatomic, strong) AVPlayerLayer* playerLayer;

@end

@implementation ISYSSnapStoryViewController

#pragma mark - Properties
- (SnapTimerView *)timerView {
    if (!_timerView) {
        _timerView = [[SnapTimerView alloc] initWithFrame:CGRectMake(20.0, 20.0, 30.0, 30.0)];
    }
    return _timerView;
}
- (RTSpinKitView *)spinner {
    if (!_spinner) {
        RTSpinKitView* spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleCircle];
        spinner.color = [UIColor colorWithWhite:0.8f alpha:1.0f];
        [self.view addSubview:spinner];
        spinner.center = self.view.center;
        self.spinner = spinner;
    }
    return _spinner;
}
-(void)setIsLoading:(BOOL)isLoading{
    _isLoading = isLoading;
    [self.spinner setHidden:!isLoading];
}
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(tap:)];
        _tapGesture.numberOfTapsRequired = 1;
        _tapGesture.numberOfTouchesRequired = 1;
    }
    return _tapGesture;
}
- (NSMutableArray *)playerItems {
    if (!_playerItems) {
        _playerItems = [NSMutableArray array];
    }
    return _playerItems;
}
- (AVPlayerItem *)currentItem {
    // If currentItemIndex object is present in playerItems
    if (self.currentItemIndex < self.playerItems.count) {
        return self.playerItems[self.currentItemIndex];
    }
    return nil;
}
-(float)currentProgress {
    double currentTime = CMTimeGetSeconds(self.currentItem.currentTime);
    double total = CMTimeGetSeconds(self.currentItem.duration);
    double progress = currentTime/total;
    return progress;
}
//-(float) currentBuffer {
//    NSValue* firstBufferedRange = self.currentItem.loadedTimeRanges.firstObject;
//    CMTimeRange firstBufferedRangeValue = firstBufferedRange.CMTimeRangeValue;
//    CMTime firstBufferedRangeEndTime = CMTimeRangeGetEnd(firstBufferedRangeValue);
//    double total = CMTimeGetSeconds(self.currentItem.duration);
//    double bufferTime = CMTimeGetSeconds(firstBufferedRangeEndTime) / total;
//    return bufferTime;
//}

#pragma mark - Actions
- (void)tap:(UITapGestureRecognizer*)_aTap {
    if (self.isLoading) {
        return;
    }
    CGPoint touchPoint = [_aTap locationInView: _aTap.view];
    BOOL nextVideo = touchPoint.x >= (_aTap.view.bounds.size.width/3.0f) ? true : false;
    if(nextVideo){
        //        NSLog(@"Tap Next! x:%f y:%f", touchPoint.x, touchPoint.y);
        [self playNextVideo];
    }else{
        //        NSLog(@"Tap Prev! x:%f y:%f", touchPoint.x, touchPoint.y);
        [self playPreviousVideo];
    }
}
- (void)updateProgress:(float)currentProgress animated:(BOOL)animated {
    CGFloat innerVal = (((CGFloat)self.currentItemIndex/self.playerItems.count)*100.0);
    CGFloat outerVal = (currentProgress*100.0);
    //    if (animated) {
    [self.timerView animateInnerValue:innerVal];
    [self.timerView animateOuterValue:outerVal];
    //    } else {
    //
    //    }
}

#pragma mark - View Life Cycle
- (instancetype)initWithVideoUrls:(NSArray *)videoUrls {
    self = [super init];
    if (self) {
        self.videoUrls = videoUrls;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createPlayerItems];
    [self createPlayer];
    [self playCurrentVideo];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.playerLayer.frame = self.view.layer.bounds;
    self.timerView.frame = CGRectMake(self.view.layer.bounds.size.width-40.0, 20.0, 20.0, 20.0);
    self.spinner.center = self.view.center;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) dealloc{
    [self releasePlayerItemKVOs:self.player.currentItem];
    
    [self.playerLayer removeFromSuperlayer];
    
    self.player = nil;
    [self.playerItems removeAllObjects];
    self.playerItems = nil;
    self.playerLayer = nil;
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Private Function - Create
- (void)createPlayerItems {
    // Create playerItems
    for (NSURL * url in self.videoUrls) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
        [self.playerItems addObject:item];
    }
    
    __weak __typeof(self) weakSelf = self;
    if (self.playerItems.count > 0) {
        // Listen for PlayerItem End notification
        [NSNotificationCenter.defaultCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                        object:nil
                                                         queue:[NSOperationQueue mainQueue]
                                                    usingBlock:^(NSNotification * _Nonnull note)
         {
             if ([self.playerItems lastObject] == note.object) {
                 NSLog(@"IT REACHED THE END");
                 [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:^{
                     
                 }];
             } else {
                 NSLog(@"NEXT VIDEO");
                 [weakSelf playNextVideo];
             }
         }];
    }
}
- (void)createPlayer {
    __weak typeof(self) weakSelf = self;
    if (self.playerItems.count > 0) {
        // Create player
        self.player = [AVPlayer playerWithPlayerItem:self.playerItems[self.currentItemIndex]];
//        AVPlayerItem * testItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"https://firebasestorage.googleapis.com/v0/b/isystematic-chat.appspot.com/o/OTskm12IalYJ42tTU8LQudIzYeF3%2Fmessage_reaction_video_-Ki4CrJxC7JsHR1Cs_a7%2F1492588684179.mp4?alt=media&token=e282e01b-d099-41c4-a165-cbf78e108a7d"]];
//        self.player = [AVPlayer playerWithPlayerItem:testItem];
        [self.player setVolume:1.0f];
        
        // Listen for PlayerItem Progress notification
        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 3)
                                                  queue:dispatch_get_main_queue()
                                             usingBlock:^(CMTime time)
         {
             
             if(!weakSelf){
                 return;
             }
             
             //             float currentBuffer = [weakSelf currentBuffer];
             float currentProgress = [weakSelf currentProgress];
             [weakSelf updateProgress:currentProgress animated:YES];
         }];
        
        // Add playerLayer to view
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        self.playerLayer.player = self.player;
        [self.view.layer addSublayer:self.playerLayer];
        
        // Add TapGesture
        [self.view addGestureRecognizer:self.tapGesture];
        [self.view addSubview:self.timerView];
    }
}
#pragma mark - Private Fuctions - Play
- (void)playCurrentVideo {
    if (self.playerItems.count > 0) {
        AVPlayerItem * currentItem = self.playerItems[self.currentItemIndex];
        
        if (currentItem.status != AVPlayerStatusReadyToPlay) {
            self.isLoading = true;
        }
        [self registerPlayerItemKVOs:currentItem];
        
        [self.player replaceCurrentItemWithPlayerItem:currentItem];
        [self.player.currentItem seekToTime:CMTimeMakeWithSeconds(0.001, 10000)];
        [self.player play];
    }
}
- (void)loadNextVideo {
    if (self.currentItemIndex+1 < self.playerItems.count) {
        [self releasePlayerItemKVOs:self.player.currentItem];
        self.currentItemIndex++;
    } else {
        // Repeat currently playing item
    }
}
- (void) loadPreviousVideo {
    if (self.currentItemIndex-1 < 0) {
        // Repeat currently playing item
    } else {
        [self releasePlayerItemKVOs:self.player.currentItem];
        self.currentItemIndex--;
    }
}
- (void)playNextVideo {
    [self loadNextVideo];
    [self playCurrentVideo];
    [self updateProgress:0.0 animated:NO];
}
- (void)playPreviousVideo {
    [self loadPreviousVideo];
    [self playCurrentVideo];
    [self updateProgress:0.0 animated:NO];
}

#pragma mark - KVO Notifications
- (void)registerPlayerItemKVOs:(AVPlayerItem *)playerItem {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    [playerItem addObserver:self
                 forKeyPath:@"playbackBufferEmpty"
                    options:options
                    context:nil];
    
    [playerItem addObserver:self
                 forKeyPath:@"playbackLikelyToKeepUp"
                    options:options
                    context:nil];
    
    [playerItem addObserver:self
                 forKeyPath:@"playbackBufferFull"
                    options:options
                    context:nil];
    
    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:options
                    context:nil];
}
- (void)releasePlayerItemKVOs:(AVPlayerItem *)playerItem {
    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    [playerItem removeObserver:self forKeyPath:@"status"];
//    [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    [playerItem removeObserver:self forKeyPath:@"currentTime"];
}
//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary<NSString *,id> *)change
//                       context:(void *)context {
//    // Only handle observations for the PlayerItemContext
//    if (context != nil) {
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//        return;
//    }
//
//}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            self.isLoading = true;
        }
        
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            self.isLoading = false;
        }
        
//        if ([keyPath isEqualToString:@"status"]) {
//            AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
//            // Get the status change from the change dictionary
//            NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
//            if ([statusNumber isKindOfClass:[NSNumber class]]) {
//                status = statusNumber.integerValue;
//            }
//            // Switch over the status
//            switch (status) {
//                case AVPlayerItemStatusReadyToPlay:
//                    // Ready to Play
//                    self.isLoading = false;
//                    break;
//                case AVPlayerItemStatusFailed:
//                    // Failed. Examine AVPlayerItem.error
//                    self.isLoading = true;
//                    break;
//                case AVPlayerItemStatusUnknown:
//                    // Not ready
//                    self.isLoading = true;
//                    break;
//            }
//        }
        
//        AVPlayerItem* item = object;
//        if (item.status == AVPlayerStatusReadyToPlay) {
//            self.isLoading = false;
//        }else{
//            self.isLoading = true;
//        }
        
    }
}
@end
