//
//  BGParticle.m
//  Betelgeuse
//
//  Created by Gabriel Handford on 11/15/10.
//  Copyright 2010. All rights reserved.
//

#import "BGParticle.h"

const Vector3D kBGHiddenPosition = {-10000, -10000, 0};
const Color4 kBGEmptyColor = {0.0, 0.0, 0.0, 0.0};

@implementation BGParticle

@synthesize position=_position, color=_color, size=_size;

- (id)initWithPosition:(Vector3D)position color:(Color4)color size:(GLfloat)size {
  if ((self = [super init])) {
    _position = position;
    _color = color;
    _size = size;
  }
  return self;
}

@end
