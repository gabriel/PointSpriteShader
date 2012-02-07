#version 120

uniform sampler2D tex;
varying vec4 v_color;

void main(void) {
  gl_FragColor = texture2D(tex, gl_PointCoord) * v_color;
}