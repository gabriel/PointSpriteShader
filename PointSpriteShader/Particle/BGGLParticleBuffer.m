//
//  BGGLParticleBuffer.m
//  Betelgeuse
//
//  Created by Gabriel Handford on 11/15/10.
//  Copyright 2010. All rights reserved.
//

#import "BGGLParticleBuffer.h"
#import "BGParticle.h"
#import "GHGLUtils.h"

@implementation BGGLParticleBuffer

@synthesize vertices=_vertices, colors=_colors, capacity=_capacity;

- (id)init {
  [NSException raise:@"NSGenericException" format:@"Invalid init"];
  return nil;
}

- (id)initWithCapacity:(int)capacity {
  if ((self = [super init])) {    
    _capacity = capacity;
    _vertices = calloc(1, sizeof(PointSprite) * _capacity);
    _colors = calloc(1, sizeof(Color4) * _capacity);
    glGenBuffers(1, &_verticesID);
    glGenBuffers(1, &_colorsID);
    _needsUpdate = YES;
  }
  return self;
}

- (id)initWithCapacity:(int)capacity textureManager:(GHTextureManager *)textureManager textureName:(NSString *)textureName {
  if ((self = [self initWithCapacity:capacity])) {    
    _texture = [[textureManager textureForResource:textureName] retain];
  }
  return self;
}

- (void)dealloc {
  free(_vertices);
	free(_colors);
  glDeleteBuffers(1, &_verticesID);
	glDeleteBuffers(1, &_colorsID);  
  [_texture release];
  [super dealloc];
}

- (void)updateForParticles:(NSArray */*of BGParticle*/)particles {
  NSInteger particleCount = [particles count];
  for (NSInteger i = 0; i < _capacity; i++) {
    if (i < particleCount) {
      BGParticle *particle = [particles objectAtIndex:i];
      _vertices[i].position = particle.position;
      _vertices[i].size = particle.size;
      _colors[i] = particle.color;
    } else {
      _vertices[i].position = kBGHiddenPosition;
      _vertices[i].size = 0;
    }
  }
  _needsUpdate = YES;
  //[self updateBuffer];
}

- (void)updateBuffer {
  // Now we have updated all the particles, update the VBOs with the arrays we have just updated
  glEnableClientState(GL_VERTEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, _verticesID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(PointSprite) * _capacity, _vertices, GL_DYNAMIC_DRAW);
  glEnableClientState(GL_COLOR_ARRAY);  
	glBindBuffer(GL_ARRAY_BUFFER, _colorsID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(Color4) * _capacity, _colors, GL_DYNAMIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, 0);  
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
  GHGLCheckError();
}

- (void)addParticle:(BGParticle *)particle {
  int index = _currentIndex % _capacity;
  _vertices[index].position = particle.position;
  _vertices[index].size = particle.size;
  _colors[index] = particle.color;
  _currentIndex++;
  _currentIndex = _currentIndex % _capacity;
  _needsUpdate = YES;
}

#if TARGET_OS_IPHONE

- (void)draw {
  
  glEnable(GL_TEXTURE_2D);
  [_texture bind];

  // Enable and configure point sprites which we are going to use for our particles
	glEnable(GL_POINT_SPRITE_OES);

  glTexEnvf(GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE);
  
  //glPointSize(32.0f);
  
  // Enable vertex arrays
	glEnableClientState(GL_VERTEX_ARRAY);
  // Bind to the vertices VBO which has been created
  glBindBuffer(GL_ARRAY_BUFFER, _verticesID);
  
  // Configure the vertex pointer which will use the vertices VBO
	glVertexPointer(3, GL_FLOAT, sizeof(PointSprite), 0);
	
	// Enable the point size array
	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	
	// Configure the point size pointer which will use the currently bound VBO.  PointSprite contains
	// both the location of the point as well as its size, so the config below tells the point size
	// pointer where in the currently bound VBO it can find the size for each point
	glPointSizePointerOES(GL_FLOAT, sizeof(PointSprite), (GLvoid *)(sizeof(GL_FLOAT)*3));
	
  // Enable the use of the color array
	glEnableClientState(GL_COLOR_ARRAY);  
  // Bind to the color VBO which has been created
	glBindBuffer(GL_ARRAY_BUFFER, _colorsID);  
  
	// Configure the color pointer specifying how many values there are for each color and their type
	glColorPointer(4, GL_FLOAT, 0, 0);
  
  // Now that all of the VBOs have been used to configure the vertices, pointer size and color
	// use glDrawArrays to draw the points
	glDrawArrays(GL_POINTS, 0, _capacity);
  
  // Unbind the current VBO
	glBindBuffer(GL_ARRAY_BUFFER, 0);
  
  // Disable the client states which have been used incase the next draw function does 
	// not need or use them
	glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
  glDisableClientState(GL_VERTEX_ARRAY);
	glDisable(GL_POINT_SPRITE_OES);
  glDisable(GL_TEXTURE_2D);
}

#else

- (void)draw {
  if (_needsUpdate) {
    [self updateBuffer];
    _needsUpdate = NO;
  }
  
  glEnableClientState(GL_VERTEX_ARRAY);
  glBindBuffer(GL_ARRAY_BUFFER, _verticesID);
  glVertexPointer(4, GL_FLOAT, sizeof(PointSprite), 0);

  glEnableClientState(GL_COLOR_ARRAY);
  glBindBuffer(GL_ARRAY_BUFFER, _colorsID);
  glColorPointer(4, GL_FLOAT, sizeof(Color4), 0);

  glDrawArrays(GL_POINTS, 0, _capacity);
  
  glBindBuffer(GL_ARRAY_BUFFER, 0);

  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_VERTEX_ARRAY);
}

#endif

@end
