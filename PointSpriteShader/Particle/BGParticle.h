//
//  BGParticle.h
//  Betelgeuse
//
//  Created by Gabriel Handford on 11/15/10.
//  Copyright 2010. All rights reserved.
//

#import "GHGLCommon.h"


extern const Vector3D kBGHiddenPosition;
extern const Color4 kBGEmptyColor;


@interface BGParticle : NSObject {
	Vector3D _position;
	Color4 _color;
	GLfloat _size;
}

@property (assign, nonatomic) Vector3D position;
@property (assign, nonatomic) Color4 color;
@property (assign, nonatomic) GLfloat size;

- (id)initWithPosition:(Vector3D)position color:(Color4)color size:(GLfloat)size;

@end
