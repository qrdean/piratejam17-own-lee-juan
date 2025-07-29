#version 330

out vec3 normal;

void main() {
  normal = gl_Normal;
  gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}


