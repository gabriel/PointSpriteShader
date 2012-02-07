//
//  GHTextureManager.m
//  Betelgeuse
//
//  Created by Gabriel Handford on 12/25/09.
//  Copyright 2009. All rights reserved.
//

#import "GHTextureManager.h"


@implementation GHTextureManager

+ (GHTextureManager *)sharedManager {
  static GHTextureManager *SharedManager = NULL;
  if (SharedManager == NULL) {
    SharedManager = [[GHTextureManager alloc] init];
  }
  return SharedManager;
}

- (id)init {
  if ((self = [super init])) {
    _textures = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)dealloc {
  [_textures release];
  [super dealloc];
}

- (void)addTexture:(id<GHGLTexture>)texture forKey:(id)key {
  [_textures setObject:texture forKey:key];
}

- (id<GHGLTexture>)textureForKey:(id)key {
  return [_textures objectForKey:key];
}

- (id<GHGLTexture>)textureForResource:(NSString *)resource {
  id<GHGLTexture> texture = [_textures objectForKey:resource];
  if (texture) return texture;
  
  texture = [[GHGLTexture alloc] initWithName:resource];
  [self addTexture:texture forKey:resource];
  [texture release];
  return texture;
}

@end
