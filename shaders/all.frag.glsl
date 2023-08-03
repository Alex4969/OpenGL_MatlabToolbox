#version 450 core

out vec4 fragColor;

in vec3 vNormal;
in vec3 vCrntPos;
in vec4 vColor;     //COL3 COL4
in vec2 vTextureCoord; //TEX
in vec2 interpolation;

uniform vec4 uFaceColor = vec4(1.0);        //DEF
uniform vec4 uLineColor = vec4(0.0);
uniform vec4 uPointColor;
uniform float uLineSize = 3.0;
uniform int  uQuoiAfficher = 1;
uniform sampler2D uTexture; //TEX
layout (std140, binding = 1) uniform camera {
    vec3 uCamPos;
};

layout (std140, binding = 0) uniform light {
    vec3 ulightPos  ;
    vec3 uLightColor; 
    vec3 uLightDir  ; 
    vec3 uLightData ; 
};

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
    if (uLightData.x == 1.0){
        intensiteLumineuse = pointLight(vCrntPos, laNormale, uCamPos, ulightPos, uLightData.y, uLightData.z);
    } else if (uLightData.x == 2.0) {
        intensiteLumineuse = direcLight(vCrntPos, laNormale, uCamPos, uLightDir);
    } else if (uLightData.x == 3.0) {
        intensiteLumineuse = spotLight(vCrntPos, laNormale, uCamPos, ulightPos, uLightDir, uLightData.y, uLightData.z);
    }
    vec4 couleurAvant = texture(uTexture, vTextureCoord); //TEX
    vec4 couleurAvant = uFaceColor; //DEF
    vec4 couleurAvant = vColor; //COL3 COL4

    vec3 laCouleur = couleurAvant.xyz;
    if (uQuoiAfficher > 1){
        vec3 barys = vec3(interpolation.x, interpolation.y, 1 - interpolation.x - interpolation.y);
        float centre = min(barys.x, min(barys.y, barys.z));
        centre = smoothstep(0.0, uLineSize * fwidth(centre), centre);
        laCouleur = (centre * laCouleur + (1.0 - centre) * uLineColor.xyz) * uLightColor * intensiteLumineuse;
    } else {
        laCouleur = laCouleur * uLightColor * intensiteLumineuse;
    }
    fragColor = vec4(laCouleur, couleurAvant.w);
}

float pointLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightPos, in float a, in float b)
// lumiere qui s'attenue en fonction de la distance (= ampoule)
{
    vec3 lightVec = lightPos - crntPos;
    float dist = length(lightVec);
    float intensity = 1.0 / (a * dist * dist + b * dist + 1.0);

    //ambient lighting
    float ambient = 0.3f;

    //diffuse lighting
    lightVec = normalize(lightVec);
    float diffuse = max(0.0f, dot(normal, lightVec));

    // speculat lighting
    float specularLight = 0.5f;
    vec3 viewDirection = normalize(camPos - crntPos);
    vec3 reflectionDir  = reflect(-lightVec, normal);
    float specAmount = pow(max(dot(viewDirection, reflectionDir), 0.0f), 8);
    float specular = specAmount * specularLight;

    return (diffuse * intensity + ambient + specular * intensity);
};

float direcLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightDirection)
//tous les rayons sont paralelle (= soleil)
{
    //ambient lighting
    float ambient = 0.3f;

    //diffuse lighting
    vec3 lightDir = normalize(-lightDirection); /*direction inverse de la lumiere*/
    float diffuse = max(0.0f, dot(normal, lightDir));

    // speculat lighting
    float specularLight = 0.5f;
    vec3 viewDirection = normalize(camPos - crntPos);
    vec3 reflectionDir  = reflect(-lightDir, normal);
    float specAmount = pow(max(dot(viewDirection, reflectionDir), 0.0f), 8);
    float specular = specAmount * specularLight;

    return (diffuse + ambient + specular);
};

float spotLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightPos, in vec3 lightDir, in float coneInterne, in float coneExterne)
// cone de lumiere (= projecteur)
{
    lightDir = normalize(lightDir);
    //ambient lighting
    float ambient = 0.3f;

    //diffuse lighting
    vec3 lightVec = normalize(lightPos - crntPos);
    float diffuse = max(0.0f, dot(normal, lightVec));

    // speculat lighting
    float specularLight = 0.5f;
    vec3 viewDirection = normalize(camPos - crntPos);
    vec3 reflectionDir  = reflect(-lightVec, normal);
    float specAmount = pow(max(dot(viewDirection, reflectionDir), 0.0f), 8);
    float specular = specAmount * specularLight;

    float angle = dot(lightDir, -lightVec);
    float intensity = clamp( (angle - coneExterne)/(coneInterne - coneExterne) , 0.0, 1.0);

    return (diffuse * intensity + ambient + specular * intensity);
};