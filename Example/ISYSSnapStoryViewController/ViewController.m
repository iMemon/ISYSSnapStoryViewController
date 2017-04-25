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
                            [NSURL URLWithString:@"https://cdn.vvvvvvv.space/v/4f566b31-2640-4446-b3a0-9b5c59664641.mp4"],
                            [NSURL URLWithString:@"https://cdn.vvvvvvv.space/v/18c3f1f0-63ad-4378-acd1-0ddc9e9bd595.mp4"],
                            [NSURL URLWithString:@"https://cdn.vvvvvvv.space/v/b79e3002-1465-478a-bd53-202189d00114.mp4"],
                            [NSURL URLWithString:@"https://cdn.vvvvvvv.space/v/baed6f59-92ea-4612-a1e0-28d3e182a904.mp4"],
                            [NSURL URLWithString:@"https://cdn.vvvvvvv.space/v/0dab26e9-adb7-4259-8315-891c628be016.mp4"],
                            [NSURL URLWithString:@"https://cdn.vvvvvvv.space/v/797bcb7d-8a13-4cde-b60e-ed22d4b7c2be.mp4"],
                            [NSURL URLWithString:@"https://cdn.vvvvvvv.space/v/17132723-59bd-4916-9d28-4369504773c4.mp4"]
                            ];
    ISYSSnapStoryViewController * controller = [[ISYSSnapStoryViewController alloc] initWithVideoUrls:videoUrls];
    [self presentViewController:controller animated:YES completion:^{
        
    }];
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
