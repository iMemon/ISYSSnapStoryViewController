//
//  ViewController.m
//  SnapchatStoryPlayer
//
//  Created by clines192 on 24/04/2017.
//  Copyright © 2017 iSystematic LLC. All rights reserved.
//

#import "ViewController.h"
@import ISYSSnapStoryViewController;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onPresent:(id)sender {
    NSArray * videoUrls = @[
                            [NSURL URLWithString:@"https://firebasestorage.googleapis.com/v0/b/isystematic-chat.appspot.com/o/YV5SmaZbwrUf5aqeVNuZnpJM5oJ3%2Fmessage_reaction_video_-Ki5r70BP8mdi7PQmB7T%2F1492616271961.mp4?alt=media&token=b9c3de52-eabd-411d-9e7b-c6a9543c7cfc"],
                            
                            [NSURL URLWithString:@"https://firebasestorage.googleapis.com/v0/b/isystematic-chat.appspot.com/o/lGFngFbsOHhAHMygEUuER3qIoR93%2Fmessage_reaction_video_-Ki5wNs-NqkOS--pf7At%2F1492617646099.mp4?alt=media&token=1b23ecf5-2adc-4bdf-9368-7993da66c016"],
                            
                            [NSURL URLWithString:@"https://firebasestorage.googleapis.com/v0/b/isystematic-chat.appspot.com/o/i6InVOQyBZdSwCcG18EdFDrBSmL2%2Fmessage_reaction_video_-Ki5xKuoy9nkt2NTpl2N%2F1492617915148.mp4?alt=media&token=2d731894-f821-462d-991d-fb5cd05e1f83"],
                            
                            [NSURL URLWithString:@"https://firebasestorage.googleapis.com/v0/b/isystematic-chat.appspot.com/o/OTskm12IalYJ42tTU8LQudIzYeF3%2Fmessage_reaction_video_-Ki4CrJxC7JsHR1Cs_a7%2F1492588684179.mp4?alt=media&token=e282e01b-d099-41c4-a165-cbf78e108a7d"]
                            ];
    
//    NSArray * videoUrls = @[
//                            [NSURL URLWithString:@"http://mpvideo-test.b0.upaiyun.com/5813998fb092e5771.mp4"],
//                            [NSURL URLWithString:@"https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4"]
//                            ];
    
    ISYSSnapStoryViewController * controller = [[ISYSSnapStoryViewController alloc] initWithVideoUrls:videoUrls];
    [self presentViewController:controller animated:YES completion:^{
        
    }];
    
    [self testDownload];
}

- (void)testDownload {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
