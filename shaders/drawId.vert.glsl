#version 450 core

layout(location = 1) in vec3 position3;

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);  

void main()
{
    gl_Position = uCamMatrix * uModelMatrix * vec4(position3, 1.0);
};