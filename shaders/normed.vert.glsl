#version 450 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);

out	vec3 vCrntPos;
out vec3 vNormal;

void main()
{
    vec4 crntPos = uModelMatrix * vec4(position, 1.0);
    gl_Position = uCamMatrix * crntPos;

    vCrntPos = crntPos.xyz;
    vNormal = normal;
};