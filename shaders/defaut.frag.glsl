#version 450 core

out vec4 color;

in vec3 vSurfaceNormal;
in vec3 vCrntPos;

uniform vec4 uColor;

void main()
{
    color = uColor;
};