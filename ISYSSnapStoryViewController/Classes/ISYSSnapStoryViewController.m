//
//  AAMStoryViewController.m
//  SnapchatStoryPlayer
//
//  Created by clines192 on 21/04/2017.
//  Copyright © 2017 iSystematic LLC. All rights reserved.
//

@import AVFoundation;
#import "ISYSSnapStoryViewController.h"
#import "VIMediaCache.h"
#import <SpinKit/RTSpinKitView.h>
#import <CommonCrypto/CommonDigest.h>
#import <ISYSSnapStoryViewController/ISYSSnapStoryViewController-Swift.h>

#import "ISYSPlayerView.h"
#define kNotificationDownloadCompleted @"kNotificationDownloadCompleted"

//static MZDownloadManager *sharedDownloadManager;

@interface ISYSSnapStoryViewController ()

/// Array of urls which will be played
@property (nonatomic, strong) NSArray* videoUrls;

//@property (nonatomic, strong) VIResourceLoaderManager *resourceLoaderManager;

@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;

@property (nonatomic, strong) id playerTimeObserver;

@property (nonatomic, strong) AVPlayer* player;
@property (nonatomic, strong) ISYSPlayerView * playerView;
@property (nonatomic, strong) AVPlayer* nextPlayer;
@property (nonatomic, strong) AVPlayer* prevPlayer;
//@property (nonatomic, strong) AVPlayerLayer* playerLayer;
//@property (nonatomic, strong) AVPlayerLayer* nextPlayerLayer;
//@property (nonatomic, strong) AVPlayerLayer* prevPlayerLayer;

@property (nonatomic, strong) SnapTimerView * timerView;
@property (nonatomic, weak) RTSpinKitView *spinner;
@property (nonatomic, assign) BOOL isLoading;

/// Array of AVPlayerItem
@property (nonatomic, strong) NSMutableArray * playerItems;
@property (nonatomic, copy, nullable) void (^firstDownloadCompletion)(BOOL completed, AVPlayerItem *playerItem);

/// Currently playing AVPlayerItem
@property (nonatomic, assign) NSInteger currentItemIndex;

@end

@implementation ISYSSnapStoryViewController

#pragma mark - Properties
//+ (MZDownloadManager *)sharedDownloadManager {
//    static dispatch_once_t DDASLLoggerOnceToken;
//    dispatch_once(&DDASLLoggerOnceToken, ^{
//        NSString * sessionId = @"com.iSystematic.ReactionApp.MZDownloadManager.BackgroundSession";
//        sharedDownloadManager = [[MZDownloadManager alloc] initWithSession:sessionId delegate:self completion:^{
//            NSLog(@"");
//        }];
//    });
//    return sharedDownloadManager;
//}
//- (VIResourceLoaderManager *)resourceLoaderManager {
//    if (!_resourceLoaderManager) {
//        _resourceLoaderManager = [VIResourceLoaderManager new];
//    }
//    return _resourceLoaderManager;
//}
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
        self.spinner.hidden = YES;
    }
    return _spinner;
}
-(void)setIsLoading:(BOOL)isLoading{
    _isLoading = isLoading;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.spinner setHidden:!isLoading];
        (isLoading) ? [weakSelf.player pause] : [weakSelf.player play];
        if (isLoading) {
            [weakSelf updateProgress:0.0 animated:NO];
        }
    });
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
//- (AVPlayerItem *)currentItem {
//    return [self playerItemAtIndex:self.currentItemIndex];;
//}
-(float)currentProgress {
    double currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
    double total = CMTimeGetSeconds(self.player.currentItem.duration);
    double progress = currentTime/total;
    return progress;
}
-(AVPlayerItem *)playerItemAtIndex:(NSInteger)index {
    if (index>=0 && index<_videoUrls.count) {
        return _playerItems[index];
    } else {
    }
    return nil;
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
    CGFloat innerVal = (self.currentItemIndex==self.videoUrls.count+1) ? 100.0 : (((CGFloat)self.currentItemIndex+currentProgress)/(self.videoUrls.count-1))*100.0;
    CGFloat outerVal = (currentProgress*100.0);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timerView animateInnerValue:innerVal];
        [self.timerView animateOuterValue:outerVal];
    });
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
    
    ISYSPlayerView * playerView = [[ISYSPlayerView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:playerView];
    self.playerView = playerView;
    
    [self createPlayerItems];
    [self createPlayer];
    [self playCurrentVideo];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
//    self.playerLayer.frame = self.view.layer.bounds;
    self.playerView.frame = self.view.layer.bounds;
    self.playerView.layer.frame = self.view.layer.bounds;
    self.timerView.frame = CGRectMake(self.view.layer.bounds.size.width-40.0, 20.0, 20.0, 20.0);
    self.spinner.center = self.view.center;
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationDownloadCompleted object:[TWRDownloadManager sharedManager] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"download completed");
        if (!weakSelf.player) {
            [weakSelf.playerItems replaceObjectAtIndex:0 withObject:note.userInfo];
            [weakSelf createPlayer];
            [weakSelf playCurrentVideo];
        }
    }];
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
    NSLog(@"dealloc -- %@",self);
    
//    [self.playerLayer removeFromSuperlayer];
    
    [self.player removeTimeObserver:self.playerTimeObserver];
    self.playerTimeObserver = nil;
    self.player = nil;
//    [self releasePlayerItemKVOs:self.player.currentItem];
    [self.playerItems removeAllObjects];
    self.playerItems = nil;
//    self.playerLayer = nil;
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    
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
    __weak typeof(self) weakSelf = self;
    for (int index=0; index<_videoUrls.count; index++) {
        AVPlayerItem * item = [NSNull null];
        if (index==0) {
            item = [[self class] addNewDownload:_videoUrls[index] completion:self.firstDownloadCompletion];
        } else {
            item = [[self class] localDownloadedVideoFromUrl:_videoUrls[index]];
        }
        [self.playerItems addObject:item];
    }
    
    if (self.videoUrls.count > 0) {
        // Listen for PlayerItem End notification
        [NSNotificationCenter.defaultCenter addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                        object:nil
                                                         queue:[NSOperationQueue mainQueue]
                                                    usingBlock:^(NSNotification * _Nonnull note)
         {
             if ([weakSelf.playerItems lastObject] == note.object) {
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
    if (self.videoUrls.count > 0) {
        // Create player
        AVPlayerItem * playerItem = self.playerItems[self.currentItemIndex];
        // If 1st item is not downloaded, Show Loading And wait for download to complete
        if ([playerItem isEqual:[NSNull null]]) {
            self.isLoading = YES;
            return;
        }
        self.isLoading = NO;
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
        if ([self.player respondsToSelector:@selector(setAutomaticallyWaitsToMinimizeStalling:)]) {
            self.player.automaticallyWaitsToMinimizeStalling = YES;
        }
//        AVPlayerItem * testItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@"https://firebasestorage.googleapis.com/v0/b/isystematic-chat.appspot.com/o/OTskm12IalYJ42tTU8LQudIzYeF3%2Fmessage_reaction_video_-Ki4CrJxC7JsHR1Cs_a7%2F1492588684179.mp4?alt=media&token=e282e01b-d099-41c4-a165-cbf78e108a7d"]];
//        self.player = [AVPlayer playerWithPlayerItem:testItem];
        [self.player setVolume:1.0f];
        
        // Add playerLayer to view
        [self.playerView setPlayer:self.player];
//        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//        self.playerLayer.player = self.player;
//        [self.view.layer addSublayer:self.playerLayer];
        
        // Listen for PlayerItem Progress notification
        self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 3)
                                                  queue:dispatch_queue_create("player.time.queue", NULL)
                                             usingBlock:^(CMTime time)
         {
             
             if(!weakSelf){
                 return;
             }
             float currentProgress = [weakSelf currentProgress];
             [weakSelf updateProgress:currentProgress animated:YES];
         }];
        
        // Add TapGesture
        [self.view addGestureRecognizer:self.tapGesture];
        [self.view addSubview:self.timerView];
    }
}
#pragma mark - Private Fuctions - Play
- (void)playCurrentVideo {
    __weak typeof(self) weakSelf = self;
    if (self.videoUrls.count > 0) {
        AVPlayerItem * newItemToPlay = [self playerItemAtIndex:self.currentItemIndex];
        // If the item is not downloaed yet due to poor internet then show loading
        if ([newItemToPlay isEqual:[NSNull null]]) {
            self.isLoading = YES;
            // Download Current Video and Show Loading
            AVPlayerItem * localItem = [[self class] addNewDownload:_videoUrls[self.currentItemIndex] completion:^(BOOL completed, AVPlayerItem *playerItem) {
                if (weakSelf) {
                    [weakSelf.playerItems replaceObjectAtIndex:weakSelf.currentItemIndex withObject:playerItem];
                    [weakSelf playCurrentVideo];
                }
            }];
            if (![localItem isEqual:[NSNull null]]) {
                [self.playerItems replaceObjectAtIndex:self.currentItemIndex withObject:localItem];
                [self playCurrentVideo];
            }
            return;
        }
        // else play current video and download next video
        else {
            self.isLoading = NO;
            //        [self registerPlayerItemKVOs:newItemToPlay];
            [self.player replaceCurrentItemWithPlayerItem:newItemToPlay];
            [self.player.currentItem seekToTime:kCMTimeZero];
            [self.player play];
            NSInteger nextIndex = self.currentItemIndex+1;
            if (nextIndex<self.videoUrls.count) {
                [[self class] addNewDownload:_videoUrls[nextIndex] completion:^(BOOL completed, AVPlayerItem *playerItem) {
                    [weakSelf.playerItems replaceObjectAtIndex:nextIndex withObject:playerItem];
                }];
            }
        }
    }
}
- (void)loadNextVideo {
    if (self.currentItemIndex+1 < self.videoUrls.count) {
//        [self releasePlayerItemKVOs:self.player.currentItem];
//        [self.resourceLoaderManager cancelLoaders];
        self.currentItemIndex+=1;
    } else {
        // Repeat currently playing item
    }
}
- (void) loadPreviousVideo {
    if (self.currentItemIndex-1 < 0) {
        // Repeat currently playing item
    } else {
//        [self releasePlayerItemKVOs:self.player.currentItem];
//        [self.resourceLoaderManager cancelLoaders];
        self.currentItemIndex-=1;
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
//    [playerItem addObserver:self
//                 forKeyPath:@"playbackBufferEmpty"
//                    options:options
//                    context:nil];
//    
//    [playerItem addObserver:self
//                 forKeyPath:@"playbackLikelyToKeepUp"
//                    options:options
//                    context:nil];
    
//    [playerItem addObserver:self
//                 forKeyPath:@"playbackBufferFull"
//                    options:options
//                    context:nil];
//    
//    [playerItem addObserver:self
//                 forKeyPath:@"status"
//                    options:options
//                    context:nil];
}
- (void)releasePlayerItemKVOs:(AVPlayerItem *)playerItem {
//    [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
//    [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
//    [playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
//    [playerItem removeObserver:self forKeyPath:@"status"];
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
        
//        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
//            self.isLoading = true;
//        }
//        
//        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
//            self.isLoading = false;
//        }
        
        AVPlayerItem * currentItem = self.playerItems[self.currentItemIndex];
        __weak typeof(self) weakSelf = self;
        if (object == currentItem && [keyPath isEqualToString:@"status"]) {
            NSLog(@"player status %@, rate %@, error: %@", @(currentItem.status), @(self.player.rate), currentItem.error);
            if (currentItem.status == AVPlayerItemStatusReadyToPlay) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    weakSelf.isLoading = NO;
                });
            } else if (currentItem.status == AVPlayerItemStatusFailed) {
                // something went wrong. player.error should contain some information
                NSLog(@"player error %@", currentItem.error);
            } else {
                weakSelf.isLoading = NO;
            }
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

//#pragma mark - MZDownloadManagerDelegate
//- (void)downloadRequestDidUpdateProgress:(MZDownloadModel *)downloadModel index:(NSInteger)index{
//    NSLog(@"Progress delegate");
//}
//- (void)downloadRequestFinished:(MZDownloadModel *)downloadModel index:(NSInteger)index {
//    NSLog(@"Download Finished");
//}
//- (void)downloadRequestDidPopulatedInterruptedTasks:(NSArray<MZDownloadModel *> *)downloadModels {
//    NSLog(@"InterruptedTasks delegate");
//}
//- (NSString *)downloadFolderPath {
//    return [[MZUtility baseFilePath] stringByAppendingPathComponent:@"Videos"];
//}
//+ (NSString *)filePathWithURL:(NSString *)urlString {
//    NSString * downloadFolderPath = [self downloadFolderPath];
//    NSString * fileName = [self cachedFileNameForKey:[urlString componentsSeparatedByString:@"?"][0]];
//    NSString * filePath = [downloadFolderPath stringByAppendingPathComponent:fileName];
//    return filePath;
//}
+ (nullable NSString *)cachedFileNameForKey:(nullable NSString *)key {
    const char *str = key.UTF8String;
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [key.pathExtension isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", key.pathExtension]];
    
    return filename;
}
////Oppotunity to handle destination does not exists error
////This delegate will be called on the session queue so handle it appropriately
//- (void)downloadRequestDestinationDoestNotExists:(MZDownloadModel *)downloadModel index:(NSInteger)index location:(NSURL *)location {
//    NSString * downloadFolderPath = [self downloadFolderPath];
//    BOOL folderAlreadyCreated = [[NSFileManager defaultManager] fileExistsAtPath:downloadFolderPath];
//    if (!folderAlreadyCreated) {
//        // Create download folder
//        @try {
//            [[NSFileManager defaultManager] createDirectoryAtPath:downloadFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
//            // Move file to download folder
//        } @catch (NSException *exception) {
//            NSLog(@"Error: Download directory can't be created");
//        }
//    } else {
//        // Move file to download folder
//        @try {
//            NSString * filePath = [self filePathWithURL:downloadModel.fileName];
//            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:nil];
//            NSLog(@"File downloaded");
//        } @catch (NSException *exception) {
//            NSLog(@"Error: File can't be moved to download folder");
//        }
//    }
//}


#pragma mark - Download Manager Methods
+ (AVPlayerItem *)localDownloadedVideoFromUrl:(NSURL *)url {
    NSString * urlString = url.absoluteString;
    NSString * fileName = [self cachedFileNameForKey:[urlString componentsSeparatedByString:@"?"][0]];
    TWRDownloadManager * manager = [TWRDownloadManager sharedManager];
    if ([manager fileExistsWithName:fileName]) {
        AVPlayerItem * item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:[manager localPathForFile:fileName]]];
        return item;
    }
    return [NSNull null];
}
+ (AVPlayerItem *)addNewDownload:(NSURL *)url completion:(void(^)(BOOL completed, AVPlayerItem * playerItem))completion {
    NSString * urlString = url.absoluteString;
    NSString * fileName = [self cachedFileNameForKey:[urlString componentsSeparatedByString:@"?"][0]];
    TWRDownloadManager * manager = [TWRDownloadManager sharedManager];
    
    void (^progressBlock)(CGFloat progress) = ^void(CGFloat progress) {
        NSLog(@"progress: %f",progress);
    };
    
    if ([manager fileExistsWithName:fileName]) {
        NSLog(@"File already exists!");
        AVPlayerItem * item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:[manager localPathForFile:fileName]]];
        return item;
    } else if(![manager isFileDownloadingForUrl:urlString withProgressBlock:progressBlock completionBlock:^(BOOL completed) {
        NSURL * newUrl = (completed)?[NSURL fileURLWithPath:[manager localPathForFile:fileName]] : nil;
        NSLog(@"completed already");
        if(completed) {
            completion(completed, [AVPlayerItem playerItemWithURL:newUrl]);
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadCompleted object:manager userInfo:[AVPlayerItem playerItemWithURL:newUrl]];
        }
    }]) {
        // Dowload file
        [[TWRDownloadManager sharedManager] downloadFileForURL:urlString withName:fileName inDirectoryNamed:nil progressBlock:progressBlock completionBlock:^(BOOL completed) {
            NSURL * newUrl = (completed)?[NSURL fileURLWithPath:[manager localPathForFile:fileName]] : nil;
            NSLog(@"completed");
            if(completed) {
                completion(completed, [AVPlayerItem playerItemWithURL:newUrl]);
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDownloadCompleted object:manager userInfo:[AVPlayerItem playerItemWithURL:newUrl]];
            }
        } enableBackgroundMode:YES];
    }
    return [NSNull null];
}
@end
