#version 450 core

layout(location = 1) in vec2 position2; //POS2
layout(location = 1) in vec3 position3; //POS3
layout(location = 2) in vec3 color;     //COL3
layout(location = 2) in vec4 color;     //COL4
layout(location = 3) in vec2 textCoord; //TEX

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);

out vec2 vTextCoord;    //TEX

out vec4 vColor;        //COL3 COL4       

void main()
{
    vec3 position3 = vec3(position2, 0.0); //POS2
    gl_Position = uCamMatrix * uModelMatrix * vec4(position3, 1.0);
    vTextCoord = textCoord;     //TEX
    vColor = vec4(color, 1.0);  //COL3
    vColor = color;             //COL4
};