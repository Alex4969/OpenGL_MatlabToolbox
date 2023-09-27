#version 450 core

layout(location = 1) in vec3 position3D;
layout(location = 2) in vec3 color3D;    /*CHOIX : COL3 */
layout(location = 2) in vec4 color4D;    /*CHOIX : COL4 */
layout(location = 3) in vec2 textureCoord;  /*CHOIX : TEX */
layout(location = 4) in vec3 normal;     /*CHOIX : NORM */

uniform mat4 uModelMatrix = mat4(1.0);

out DATA {
	vec3 vCrntPos;
    vec2 vTextureCoord; /*CHOIX : TEX */
    vec4 vColor;        /*CHOIX : COL3 COL4 */
    vec3 vNormal;       /*CHOIX : NORM */
} data_out;

void main() {
    vec4 crntPos = uModelMatrix * vec4(position3D, 1.0);
    gl_Position = crntPos;

    data_out.vCrntPos = crntPos.xyz;
    data_out.vColor = color4D;                /*CHOIX : COL4 */
    data_out.vColor = vec4(color3D, 1.0);     /*CHOIX : COL3 */
    data_out.vTextureCoord = textureCoord;    /*CHOIX : TEX */
    mat3 rotation = mat3(uModelMatrix);       /*CHOIX : NORM */
    data_out.vNormal = rotation * normal;     /*CHOIX : NORM */
}