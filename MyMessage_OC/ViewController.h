//
//  ViewController.h
//  MyMessage_OC
//
//  Created by dixon on 16/6/29.
//  Copyright © 2016年 Monaco1. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,UINavigationControllerDelegate>
{
    IBOutlet UITableView *tv;
}

@end

