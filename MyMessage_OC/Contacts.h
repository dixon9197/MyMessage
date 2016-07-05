//
//  Contacts.h
//  MyMessage_OC
//
//  Created by dixon on 16/6/29.
//  Copyright © 2016年 Monaco1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contacts : NSObject<NSCoding>
@property(readwrite)NSString *name;
@property(readwrite)NSString *contactAddress;
@property(readwrite)BOOL isSelect;

-(instancetype)initWithName:(NSString*)name contactAddress:(NSString*)contactAddress;

@end
