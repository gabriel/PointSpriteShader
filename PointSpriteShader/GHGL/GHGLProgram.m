//
//  GHGLProgram.m
//  Betelgeuse
//
//  Created by Gabriel Handford on 10/26/10.
//  Copyright 2010. All rights reserved.
//

#import "GHGLProgram.h"
#import "GHGLDefines.h"

@interface GHGLProgram ()
- (BOOL)_linkProgram:(GLuint)prog;
- (BOOL)_validateProgram:(GLuint)prog;
- (BOOL)_compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
@end


@implementation GHGLProgram

@synthesize program=_program;

- (id)init {
  if ((self = [super init])) {
    _program = glCreateProgram();
  }
  return self;
}

- (void)dealloc {
  if (_vertexShader) {
    glDeleteShader(_vertexShader);
    _vertexShader = 0;
  }
  if (_fragmentShader) {
    glDeleteShader(_fragmentShader);
    _fragmentShader = 0;
  }
  if (_program) {
    glDeleteProgram(_program);
    _program = 0;
  }
  [super dealloc];
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
  BOOL compiled = [self _compileShader:shader type:type file:file];
  if (!compiled) [NSException raise:NSInternalInconsistencyException format:@"Failed to compile: %@", file];
}

- (BOOL)_compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
  GLint status;
  const GLchar *source;
  
  source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
  if (!source) {
    GHGLError(@"Failed to load shader at path: %@", file);
    return NO;
  }
  
  *shader = glCreateShader(type);
  glShaderSource(*shader, 1, &source, NULL);
  glCompileShader(*shader);
  
#if DEBUG
  GLint logLength;
  glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetShaderInfoLog(*shader, logLength, &logLength, log);
    GHGLError(@"Shader compile log:\n%s", log);
    free(log);
  }
#endif
  
  glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
  if (status == 0) {
    GHGLError(@"Shader compile error");
    glDeleteShader(*shader);
    return NO;
  }
  
  return YES;
}

- (void)linkProgram {
  if (!_program) [NSException raise:NSInternalInconsistencyException format:@"No program available"];
  BOOL linked = [self _linkProgram:_program];
  if (!linked) [NSException raise:NSInternalInconsistencyException format:@"Failed to link program"];
}

- (BOOL)_linkProgram:(GLuint)prog {
  GLint status;
  
  glLinkProgram(prog);
  
#if DEBUG
  GLint logLength;
  glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(prog, logLength, &logLength, log);
    NSLog(@"Program link log:\n%s", log);
    free(log);
  }
#endif
  
  glGetProgramiv(prog, GL_LINK_STATUS, &status);
  if (status == 0)
    return NO;
  
  return YES;
}

- (void)validateProgram {
  if (!_program) [NSException raise:NSInternalInconsistencyException format:@"No program available"];
  BOOL validated = [self _validateProgram:_program];
  if (!validated) [NSException raise:NSInternalInconsistencyException format:@"Failed to validate program"];
}

- (BOOL)_validateProgram:(GLuint)program {
  GLint logLength, status;
  
  glValidateProgram(program);
  glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(program, logLength, &logLength, log);
    NSLog(@"Program validate log:\n%s", log);
    free(log);
  }
  
  glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
  if (status == 0)
    return NO;
  
  return YES;
}

- (void)attachShaders:(NSString *)name {
  // Create and compile vertex shader.  
  NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
  [self compileShader:&_vertexShader type:GL_VERTEX_SHADER file:vertShaderPathname];
  
  // Create and compile fragment shader.
  NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
  [self compileShader:&_fragmentShader type:GL_FRAGMENT_SHADER file:fragShaderPathname];
  
  // Attach vertex shader to program.
  glAttachShader(_program, _vertexShader);
  
  // Attach fragment shader to program.
  glAttachShader(_program, _fragmentShader);  
}

- (void)releaseShaders {
  // Release vertex and fragment shaders.
  if (_vertexShader) {
    glDetachShader(_program, _vertexShader);
    glDeleteShader(_vertexShader);
    _vertexShader = 0;
  }
  if (_fragmentShader) {
    glDetachShader(_program, _fragmentShader);
    glDeleteShader(_fragmentShader);
    _fragmentShader = 0;
  }
}

@end
