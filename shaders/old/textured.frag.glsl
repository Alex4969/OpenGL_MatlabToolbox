#version 450 core

out vec4 color;             //SORTIE : la couleur de ce pixel

in vec3 vSurfaceNormal;     //ENTREE DEPUIS GEOM : la normale a la surface
in vec3 vCrntPos;           //ENTREE DEPUIS VERT : la position du point (avant projection!)
in vec2 vTextureCoord;      //ENTREE DEPUIS BUFFER : la couleur du point

uniform sampler2D uTexture; //n slot de la texture a appliquee
uniform vec3 uLightColor;   //couleur de la lumiere
uniform vec3 uLightPos;     //position de la lumiere
uniform vec3 uCamPos;       //position de la camera
uniform vec3 uLightDir ;    //Direction de la lumiere pour la directionel et la spotlight
uniform vec3 uLightData;    //[type, a, b] type {0=desactive, 1=point, 2=direct, 3=spot}
                            // a et b parametre pour point ou spot

float pointLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightPos, in float a, in float b);
float direcLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightDirection);
float spotLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightPos, in vec3 lightDir, in float coneInterne, in float coneExterne);

void main()
{
    float intensiteLumineuse = 1.0;
    if (uLightData.x == 1.0){
        intensiteLumineuse = pointLight(vCrntPos, vSurfaceNormal, uCamPos, uLightPos, uLightData.y, uLightData.z);
    } else if (uLightData.x == 2.0) {
        intensiteLumineuse = direcLight(vCrntPos, vSurfaceNormal, uCamPos, uLightDir);
    } else if (uLightData.x == 3.0) {
        intensiteLumineuse = spotLight(vCrntPos, vSurfaceNormal, uCamPos, uLightPos, uLightDir, uLightData.y, uLightData.z);
    }
    vec4 texColor = texture(uTexture, vTextureCoord);
    vec3 laCouleur = texColor.xyz * uLightColor * intensiteLumineuse;
    color = vec4(laCouleur, texColor.w);
}