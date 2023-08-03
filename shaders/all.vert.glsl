#version 450 core

layout(location = 1) in vec2 position2D; //POS2
layout(location = 1) in vec3 position3D; //POS3
layout(location = 2) in vec3 color3D;    //COL3   
layout(location = 2) in vec4 color4D;    //COL4
layout(location = 3) in vec2 textureCoord;  //TEX
layout(location = 4) in vec3 normal;     //NORM

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);

out DATA {
	vec3 vCrntPos;
	mat4 vProjection;
    vec2 vTextureCoord; //TEX
    vec4 vColor;        //COL3, COL4
    vec3 vNormal;       //NORM
} data_out;

void main() {
    vec3 position3D = vec3(position2D, 0.0);            //POS2
    vec4 crntPos = uModelMatrix * vec4(position3D, 1.0);
    gl_Position = crntPos;

    data_out.vCrntPos = crntPos.xyz;
    data_out.vProjection = uCamMatrix;
    data_out.vColor = color4D;                //COL4
    data_out.vColor = vec4(color3D, 1.0);     //COL3
    data_out.vTextureCoord = textureCoord;    //TEX
    mat3 rotation = mat3(uModelMatrix);       //NORM
    data_out.vNormal = rotation * normal;     //NORM
}
