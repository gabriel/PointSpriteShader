//
//  BGGLParticleBuffer.h
//  Betelgeuse
//
//  Created by Gabriel Handford on 11/15/10.
//  Copyright 2010. All rights reserved.
//

#import "GHGLCommon.h"
#import "GHGLTexture.h"
#import "GHTextureManager.h"
#import "BGParticle.h"

typedef struct {
} BGGLParticle;  

@interface BGGLParticleBuffer : NSObject {

  int _capacity;
  
  PointSprite *_vertices;
	Color4 *_colors;
  GLuint _verticesID;
	GLuint _colorsID;
  
  BOOL _needsUpdate;
  int _currentIndex;
  
  id<GHGLTexture> _texture;  
}

@property (readonly, nonatomic) PointSprite *vertices;
@property (readonly, nonatomic) Color4 *colors;
@property (readonly, nonatomic) int capacity;

- (id)initWithCapacity:(int)capacity;

- (id)initWithCapacity:(int)capacity textureManager:(GHTextureManager *)textureManager textureName:(NSString *)textureName;

- (void)updateForParticles:(NSArray */*of BGParticle*/)particles;

- (void)updateBuffer;

- (void)draw;

- (void)addParticle:(BGParticle *)particle;

@end
