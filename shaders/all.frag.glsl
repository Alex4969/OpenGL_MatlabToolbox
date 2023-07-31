#version 450 core

out vec4 fragColor;

in vec3 vNormal;
in vec3 vCrntPos;
in vec4 vColor;     //COL3 COL4
in vec2 vTextureCoord; //TEX

uniform vec4 uColor;        //DEF
uniform sampler2D uTexture; //TEX
uniform vec3 uCamPos;

layout (std140, binding = 0) uniform light {
    vec3 uLightPos  ;
    vec3 uLightColor; 
    vec3 uLightDir  ; 
    vec3 uLightData ; 
} l;

float pointLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightPos, in float a, in float b);
float direcLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightDirection);
float spotLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightPos, in vec3 lightDir, in float coneInterne, in float coneExterne);

void main()
{
    vec3 laNormale = normalize(vNormal);
    float intensiteLumineuse = 1.0;
    if (l.uLightData.x == 1.0){
        intensiteLumineuse = pointLight(vCrntPos, laNormale, uCamPos, l.uLightPos, l.uLightData.y, l.uLightData.z);
    } else if (l.uLightData.x == 2.0) {
        intensiteLumineuse = direcLight(vCrntPos, laNormale, uCamPos, l.uLightDir);
    } else if (l.uLightData.x == 3.0) {
        intensiteLumineuse = spotLight(vCrntPos, laNormale, uCamPos, l.uLightPos, l.uLightDir, l.uLightData.y, l.uLightData.z);
    }
    vec4 couleurAvant = texture(uTexture, vTextureCoord); //TEX
    vec4 couleurAvant = uColor; //DEF
    vec4 couleurAvant = vColor; //COL3 COL4
    vec3 laCouleur = couleurAvant.xyz * l.uLightColor * intensiteLumineuse;
    fragColor = vec4(laCouleur, couleurAvant.w);
}
