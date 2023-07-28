#version 450 core

out vec4 fragColor;

in vec4 vColor;     //COL3 COL4
in vec2 vTextCoord; //TEX

uniform sampler2D uTexture; //TEX
uniform vec4 uColor = vec4(1.0, 1.0, 1.0, 1.0); //TEX
uniform vec4 uColor; //DEF

void main()
{
   fragColor = vColor;    //COL3 COL4
   fragColor = texture(uTexture, vTextCoord) * uColor; //TEX
   fragColor = uColor; //DEF
};