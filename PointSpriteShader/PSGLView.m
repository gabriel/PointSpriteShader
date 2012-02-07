//
//  PSGLView.m
//
//  Created by Gabriel Handford on 1/14/12.
//  Copyright (c) 2012 rel.me. All rights reserved.
//

#import "PSGLView.h"
#import <OpenGL/gl.h>
#import <QuartzCore/CVDisplayLink.h>
#import <OpenGL/OpenGL.h>

#import "GHGLUtils.h"
#import "GHTextureManager.h"

@implementation PSGLView

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime, CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext) {
  return [(PSGLView *)displayLinkContext drawWithTime:inOutputTime];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  CVDisplayLinkRelease(_displayLink);
  [_program release];
  [_buffer release];
  [super dealloc];
}

- (void)windowChangedScreen:(NSNotification *)notification {
	// If the video moves to a different screen, synchronize to the timing of that screen.
  NSWindow *window = [notification object]; 
  CGDirectDisplayID displayID = (CGDirectDisplayID)[[[[window screen] deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
  
  if ((displayID != 0) && (_viewDisplayID != displayID)) {
		CVDisplayLinkSetCurrentCGDisplay(_displayLink, displayID);
		_viewDisplayID = displayID;
  }
}

- (void)start {
  NSAssert(!_displayLink, @"Already have display link");
  
  NSOpenGLPixelFormatAttribute attributes[] = {
		NSOpenGLPFAAccelerated,
		NSOpenGLPFANoRecovery,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFADepthSize, 24,
		0
  };
	
  NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
  [self setPixelFormat:pixelFormat];
  [pixelFormat release];
  
  CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowChangedScreen:) name:NSWindowDidMoveNotification object:nil];
  
  // Set up callbacks for the display link.
	CVDisplayLinkSetOutputCallback(_displayLink, DisplayLinkCallback, self);
  
  CGLContextObj cglContext = (CGLContextObj)[[self openGLContext] CGLContextObj];
  CGLPixelFormatObj cglPixelFormat = (CGLPixelFormatObj)[[self pixelFormat] CGLPixelFormatObj];
  NSAssert(cglPixelFormat, @"No pixel format");
  CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(_displayLink, cglContext, cglPixelFormat);
  
  CVReturn started = CVDisplayLinkStart(_displayLink);
  NSLog(@"Started: %d", started);
}

- (void)stop {
  CVDisplayLinkStop(_displayLink);
  CVDisplayLinkRelease(_displayLink);
}

- (BOOL)loadShaders {
  if (_program) return NO;

  _program = [[GHGLProgram alloc] init];  
  [_program attachShaders:@"Particles"];
  [_program linkProgram];
  [_program releaseShaders];
  
  _buffer = [[BGGLParticleBuffer alloc] initWithCapacity:5000]; // The total number of sprites to show at once
  
  glEnable(GL_POINT_SPRITE);
  glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);
  
  return YES;
}

- (void)setupOrtho {
	glViewport(0, 0, self.frame.size.width, self.frame.size.height);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	glOrtho(0.0f, self.frame.size.width, 0.0f, self.frame.size.height, -1.0f, 1.0f);
	glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
}	

- (void)setupView {
  GHGLDebug(@"Setup view; viewport: (%d, %d, %d, %d)", 0, 0, (int)self.frame.size.width, (int)self.frame.size.height);
  [self setupOrtho];
  
  GLfloat fSizes[2];
  glGetFloatv(GL_ALIASED_POINT_SIZE_RANGE, fSizes);
  GHGLDebug(@"Size range: %0.1f, %0.1f", fSizes[0], fSizes[1]);
  
  [self loadShaders];
}

- (void)reshape {
  [self setupView];
}

- (void)_drawParticles {
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  
  //glEnable(GL_TEXTURE_2D);
  id<GHGLTexture> texture = [[GHTextureManager sharedManager] textureForResource:@"particle64.png"];
  [texture bind];
  
  glUseProgram([_program program]);
  
  [_buffer draw];
  
  glUseProgram(0);

  //glDisable(GL_TEXTURE_2D);
  glDisable(GL_BLEND);
}

- (void)_updateForPosition:(Vector3D)position {
  if (position.y < 0 || position.x < 0 || position.y > self.frame.size.height || position.x > self.frame.size.width) return;
  
  if (position.x == _lastPosition.x && position.y == _lastPosition.y) return;
  
  //GHGLDebug(@"Position: %0.0f %0.0f", position.x, position.y);
  _lastPosition = position;
  
  BGParticle *particle = [[BGParticle alloc] initWithPosition:position color:Color4Make(1.0, 1.0, 1.0, 0.3) size:(RANDOM_0_TO_1() * 32.0) + 32.0];
  [_buffer addParticle:particle];
  [particle release];
  [self setNeedsDisplay:YES];
}

- (CVReturn)drawWithTime:(const CVTimeStamp *)outputTime {
	// There is no autorelease pool when this method is called because it will be called from a background thread
	// It's important to create one or you will leak objects
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  CGLContextObj contextObj = (CGLContextObj)[[self openGLContext] CGLContextObj];
  CGLLockContext(contextObj);
	
	[[self openGLContext] makeCurrentContext];
  
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
  [self _drawParticles];
  
  glFlush();
  [[self openGLContext] flushBuffer];
	
	CGLUnlockContext(contextObj);
  
	[pool release];
  return kCVReturnSuccess;
}

- (void)mouseDragged:(NSEvent *)event {
  NSPoint p = [event locationInWindow];
  [self _updateForPosition:Vector3DMake(p.x, p.y, 0)];
}

@end
