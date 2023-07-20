#version 450 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec2 textureCoord;

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);

out vec2 vTextureCoord;

void main()
{
    vec4 crntPos = uCamMatrix * uModelMatrix * vec4(position, 1.0);
    gl_Position = crntPos;

    vTextureCoord = textureCoord;
};