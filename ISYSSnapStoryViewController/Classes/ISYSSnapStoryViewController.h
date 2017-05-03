//
//  AAMStoryViewController.h
//  SnapchatStoryPlayer
//
//  Created by clines192 on 21/04/2017.
//  Copyright © 2017 iSystematic LLC. All rights reserved.
//

@import UIKit;
@import Foundation;
//#import <MZDownloadManager/MZDownloadManager-Swift.h>

@interface ISYSSnapStoryViewController : UIViewController
//<MZDownloadManagerDelegate>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

- (instancetype)initWithVideoUrls:(NSArray *)videoUrls;

/// Shared Download Manager
//+ (MZDownloadManager *)sharedDownloadManager;

@end
