//
//  ViewController.m
//  MHOpenDemo
//
//  Created by Apple on 2021/5/31.
//

#import "ViewController.h"
#import "MHOpenSourceViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (IBAction)startSkinCare:(UIButton *)sender {
    MHOpenSourceViewController * openSourceVC = [[MHOpenSourceViewController alloc] init];
    openSourceVC.modalPresentationStyle = 0;
    [self presentViewController:openSourceVC animated:YES completion:^{
        
    }];
}

@end
