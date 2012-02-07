//
//  PSGLView.h
//
//  Created by Gabriel Handford on 1/14/12.
//  Copyright (c) 2012 rel.me. All rights reserved.
//

#import <QuartzCore/CVDisplayLink.h>

#import "GHGLCommon.h"
#import "GHGLProgram.h"
#import "BGGLParticleBuffer.h"

@interface PSGLView : NSOpenGLView {
  CVDisplayLinkRef _displayLink;
  CGDirectDisplayID	_viewDisplayID;
  
  GHGLProgram *_program;
  
  BGGLParticleBuffer *_buffer;
  Vector3D _lastPosition;
}

- (void)start;

- (void)stop;

- (CVReturn)drawWithTime:(const CVTimeStamp *)outputTime;

@end
