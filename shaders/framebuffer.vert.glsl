#version 450 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 textCoord;

out vec2 vTextCoord;

void main()
{
    gl_Position = vec4(position, 1.0);
    vTextCoord = textCoord;
};