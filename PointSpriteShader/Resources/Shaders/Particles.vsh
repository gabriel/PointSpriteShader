
varying vec4 v_color;

void main(void) {
  vec4 pos = gl_Vertex;
  gl_PointSize = pos.w;
  pos.w = 1.0;
  gl_Position = gl_ModelViewProjectionMatrix * pos;
  v_color = gl_Color;
}