//
//  GHGLUtils.h
//  FFProcessing
//
//  Created by Gabriel Handford on 5/10/10.
//  Copyright 2010. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <OpenGLES/ES1/gl.h>
#endif

#import "GHGLCommon.h"

/*!
 Next power of two. Used for padding GL textures.
 */
NSUInteger GHGLNextPOT(NSUInteger x);

extern NSString *const GHGLExtension_GL_APPLE_texture_2D_limited_npot;
extern NSString *const GHGLExtension_GL_IMG_texture_format_BGRA8888;

BOOL GHGLCheckForExtension(NSString *name);

void GHGLGenTexImage2D(Texture *texture, const GLvoid *pixels);

NSString *GHGLErrorDescription(GLenum error);

#if DEBUG
#define GHGLAssert(expression) assert(expression)
#else
#define GHGLAssert(expression)
#endif

#if DEBUG
#define GHGLCheckError() do { \
  GLenum err = glGetError(); \
  if (err != GL_NO_ERROR) { \
    NSString *description = GHGLErrorDescription(err); \
    NSLog(@"GHGLCheckError: %@ caught at %s:%u\n", description, __FILE__, __LINE__); \
    GHGLAssert(0); \
  } \
} while (0)
#else
#define GHGLCheckError() do { } while(0)
#endif

void _GHGLValidateTexEnv(void);

#if DEBUG
#define GHGLValidateTexEnv() _GHGLValidateTexEnv()
#else
#define GHGLValidateTexEnv() do { } while (0)
#endif

CGImageRef GHGLCreateImageFromBuffer(GLubyte *buffer, int length, GLsizei width, GLsizei height, CGColorSpaceRef colorSpace);

LineSegment2D LineSegment2DMakeFromVector2D(Vector2D v1, Vector2D v2);

LineSegment2D LineSegment2DMakeFromPoints(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2);

GLfloat Line2DDistanceFromVector2D(Line2D line, Vector2D v);

BOOL LinesIntersect(Vector2D v1s, Vector2D v1e, Vector2D v2s, Vector2D v2e, Vector2D *intersection);

BOOL LineSegment2DIntersect(LineSegment2D line1, LineSegment2D line2, Vector2D *intersection);

BOOL LineSegment2DDistanceFromPoint(LineSegment2D line1, Vector2D v, GLfloat *distance);

BOOL LineSegment2DIntersectFromPoint(LineSegment2D line1, Vector2D v, Vector2D *intersection);