//
//  GHGLProgram.h
//  Betelgeuse
//
//  Created by Gabriel Handford on 10/26/10.
//  Copyright 2010. All rights reserved.
//

@interface GHGLProgram : NSObject {
  GLuint _program;  
  GLuint _vertexShader;
  GLuint _fragmentShader;
}

@property (readonly, nonatomic) GLuint program;

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;

- (void)validateProgram;

- (void)linkProgram;

/*!
 Compile and attach shader with name, for example, Shader.vsh, Shader.fsh.
 
 After linking program be sure to call releaseShaders.
 */
- (void)attachShaders:(NSString *)name;

- (void)releaseShaders;

@end
