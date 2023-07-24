#version 450 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 textCoord;

uniform mat4 uModelMatrix = mat4(1.0);

out vec2 vTextCoord;

void main()
{
    gl_Position = uModelMatrix * vec4(position, 1.0);
    vTextCoord = textCoord;
};