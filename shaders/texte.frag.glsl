#version 450 core

out vec4 color;             //SORTIE : la couleur de ce pixel

in vec2 vTextureCoord;     //ENTREE DEPUIS GEOM : la normale a la surface

uniform vec4 uTextColor = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D uTexture; //n° slot de la texture a appliquée

void main()
{
    vec4 texColor = texture(uTexture, vTextureCoord) * uTextColor;
    if (texColor.w < 0.1)
        discard;
    color = texColor;
}