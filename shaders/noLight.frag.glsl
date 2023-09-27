#version 450 core

out vec4 fragColor;

in vec4 vColor;     /*CHOIX :  COL3 COL4 */
in vec2 vTextCoord; /*CHOIX TEX */

uniform sampler2D uTexture; /*CHOIX : TEX */
uniform vec4 uColor = vec4(1.0, 1.0, 1.0, 1.0); /*CHOIX : TEX */
uniform vec4 uColor; /*CHOIX : DEF */

void main()
{
   fragColor = vColor;    /*CHOIX : COL3 COL4 */
   fragColor = texture(uTexture, vTextCoord) * uColor; /*CHOIX : TEX */
   fragColor = uColor; /*CHOIX : DEF */
};