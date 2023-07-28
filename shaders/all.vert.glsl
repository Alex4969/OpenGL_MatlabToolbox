#version 450 core

layout(location = 1) in vec2 position2D; //POS2
layout(location = 1) in vec3 position3D; //POS3
layout(location = 2) in vec3 color3D;    //COL3   
layout(location = 2) in vec4 color4D;    //COL4
layout(location = 3) in vec2 textureCoord;  //TEX
layout(location = 4) in vec3 normal;     //NORM

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);
