//
//  PSAppDelegate.m
//  PointSpriteShader
//
//  Created by Gabriel Handford on 2/7/12.
//  Copyright (c) 2012 rel.me. All rights reserved.
//

#import "PSAppDelegate.h"

@implementation PSAppDelegate

@synthesize window=_window, GLView=_GLView;

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillCloseNotification:) name:NSWindowWillCloseNotification object:nil];
  [_GLView start];
}

- (void)windowWillCloseNotification:(NSNotification *)notification {
  [_GLView stop];
}

@end
