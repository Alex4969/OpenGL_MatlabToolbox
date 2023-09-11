#version 450 core

out vec4 fragColor;

in vec3 vNormal;
in vec3 vCrntPos;
in vec4 vColor;         //COL3 COL4
in vec2 vTextureCoord;  //TEX
in vec2 interpolation;

uniform vec4 uFaceColor = vec4(1.0);    //DEF
uniform vec4 uLineColor;
uniform vec4 uPointColor;
uniform float uLineSize;
uniform float uPointSize;
uniform int  uQuoiAfficher = 1;
uniform sampler2D uTexture;             //TEX

layout (std140, binding = 0) uniform light {
    vec3 ulightPos  ;
    vec3 uLightColor; 
    vec3 uLightDir  ; 
    vec3 uLightData ;
    //Phil
    vec3 uLightParam; 
    vec3 uCamPos    ;
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
    if (uLightData.x == 1.0){   //LIGHT
        intensiteLumineuse = pointLight(vCrntPos, laNormale, uCamPos, ulightPos, uLightData.y, uLightData.z);   //LIGHT
    } else if (uLightData.x == 2.0) {   //LIGHT
        intensiteLumineuse = direcLight(vCrntPos, laNormale, uCamPos, uLightDir);   //LIGHT
    } else if (uLightData.x == 3.0) {   //LIGHT
        intensiteLumineuse = spotLight(vCrntPos, laNormale, uCamPos, ulightPos, uLightDir, uLightData.y, uLightData.z); //LIGHT
    }   //LIGHT


    

    vec4 couleur;
    if ((uQuoiAfficher & 1) > 0){
        couleur = texture(uTexture, vTextureCoord); //TEX
        couleur = uFaceColor; //DEF
        couleur = vColor; //COL3 COL4
    }

    if (uQuoiAfficher > 1){
        vec3 barys = vec3(interpolation.x, interpolation.y, 1 - interpolation.x - interpolation.y);
        float coin = max(barys.x, max(barys.y, barys.z));
        coin = smoothstep(1.0 - uPointSize * fwidth(coin), 1.0, coin);
        float centre = min(barys.x, min(barys.y, barys.z));
        centre = smoothstep(0.0, uLineSize * fwidth(centre), centre);
        switch (uQuoiAfficher) {
        case 2 : /* Arretes uniquement */
            if (centre == 1)
                discard;
            couleur = vec4(0.0) * couleur + (1.0 - centre) * uLineColor;
            break;
        case 3 : /* Arretes + faces */
            couleur = centre * couleur + (1.0 - centre) * uLineColor;
            break;
        case 4 : /* Points uniquement */
            if (coin == 0)
                discard;
            couleur = vec4(0.0) * couleur + coin * uPointColor;
            break;
        case 5 : /* Points + faces */
            couleur = (1-coin) * couleur + coin * uPointColor;
            break;
        case 6 : /* Arretes + Points */
            if (centre == 1 && coin == 0)
                discard;
            couleur = vec4(0.0) * couleur + (1.0 - centre) * uLineColor;
            couleur = (1-coin) * couleur + coin * uPointColor;
            break;
        case 7 : /* Faces + arretes + points */
            couleur = centre * couleur + (1.0 - centre) * uLineColor;
            couleur = (1-coin) * couleur + coin * uPointColor;
            break;
        }
    }

    // Phil  * uLightParam.x
    couleur.xyz *= uLightColor * intensiteLumineuse;
    couleur.xyz *= uLightParam.x;
    fragColor = couleur;
}

float pointLight(in vec3 crntPos, in vec3 normal, in vec3 camPos,
    in vec3 lightPos, in float a, in float b)
// lumiere qui s'attenue en fonction de la distance (= ampoule)
{
    vec3 lightVec = lightPos - crntPos;
    float dist = length(lightVec);
    //float intensity = 1.0 / (a * dist * dist + b * dist + 1.0);

    float intensity = exp(-a*dist);

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
// cone de lumiere (= projecteur de la Rotonde !)
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
    float intensity = clamp( (angle - coneExterne)/(coneInterne - coneExterne) , 0.0, 1.0 );

    return (diffuse * intensity + ambient + specular * intensity);
};