#version 300 es
precision mediump float;
// #version 100

in vec3 vertexPosition;
out vec3 fragPosition;

uniform mat4 mvp;

void main() {
    fragPosition = vertexPosition;
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}

