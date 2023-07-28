#version 450 core

layout(location = 1) in vec3 position;
layout(location = 2) in vec3 color;

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);

out vec3 vColor;

void main()
{
    gl_Position = uCamMatrix * uModelMatrix * vec4(position, 1.0);
    vColor = color;
};