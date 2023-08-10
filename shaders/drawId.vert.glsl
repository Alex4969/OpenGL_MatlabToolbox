#version 450 core

layout(location = 1) in vec2 position2; //POS2
layout(location = 1) in vec3 position3; //POS3

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);  

void main()
{
    vec3 position3 = vec3(position2, 0.0); //POS2
    gl_Position = uCamMatrix * uModelMatrix * vec4(position3, 1.0);
};