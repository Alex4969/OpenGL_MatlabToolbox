#version 450 core

layout(location = 1) in vec3 position3;
layout(location = 2) in vec3 color;     /*CHOIX : COL3 */
layout(location = 2) in vec4 color;     /*CHOIX : COL4 */
layout(location = 3) in vec2 textCoord; /*CHOIX : TEX */

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);

out vec2 vTextCoord;    /*CHOIX : TEX */

out vec4 vColor;        /*CHOIX : COL3 COL4 */    

void main()
{
    gl_Position = uCamMatrix * uModelMatrix * vec4(position3, 1.0);
    vTextCoord = textCoord;     /*CHOIX : TEX */
    vColor = vec4(color, 1.0);  /*CHOIX : COL3 */
    vColor = color;             /*CHOIX : COL4 */
};