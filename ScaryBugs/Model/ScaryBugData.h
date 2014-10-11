//
//  ScaryBugData.h
//  ScaryBugs
//
//  Created by Nate Armstrong on 10/6/14.
//  Copyright (c) 2014 Nate Armstrong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScaryBugData : NSObject

@property (strong) NSString *title;
@property (assign) float rating;

- (id)initWithTitle:(NSString *)title rating:(float)rating;

@end
