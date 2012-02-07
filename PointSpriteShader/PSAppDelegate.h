//
//  PSAppDelegate.h
//  PointSpriteShader
//
//  Created by Gabriel Handford on 2/7/12.
//  Copyright (c) 2012 rel.me. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSGLView.h"

@interface PSAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet PSGLView *GLView;

@end
