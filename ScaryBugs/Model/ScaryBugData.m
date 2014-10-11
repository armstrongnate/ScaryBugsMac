//
//  ScaryBugData.m
//  ScaryBugs
//
//  Created by Nate Armstrong on 10/6/14.
//  Copyright (c) 2014 Nate Armstrong. All rights reserved.
//

#import "ScaryBugData.h"

@implementation ScaryBugData

- (id)initWithTitle:(NSString *)title rating:(float)rating {
  if (self = [super init]) {
    self.title = title;
    self.rating = rating;
  }
  return self;
}

@end
