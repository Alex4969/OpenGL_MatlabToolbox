#version 450 core

out vec4 color;             //SORTIE : la couleur de ce pixel

in vec3 vNormal;            //ENTREE DEPUIS GEOM : la normale aux sommets
in vec3 vCrntPos;           //ENTREE DEPUIS VERT : la position du point (avant projection!)

uniform vec4 uColor;        //couleur de l'element
uniform vec3 uLightColor;   //couleur de la lumiere
uniform vec3 uLightPos;     //position de la lumiere
uniform vec3 uCamPos;       //position de la camera
uniform vec3 uLightDir ;    //Direction de la lumiere pour la directionel et la spotlight
uniform vec3 uLightData;    //[type, a, b] type {0=desactive, 1=point, 2=direct, 3=spot}
                            // a et b parametre pour point ou spot

float pointLight() // lumiere qui s'attenue en fonction de la distance (= ampoule)
{
    vec3 lightVec = uLightPos - vCrntPos;
    float dist = length(lightVec);
    float a = uLightData.y;
    float b = uLightData.z;
    float intensity = 1.0 / (a * dist * dist + b * dist + 1.0);

    //ambient lighting
    float ambient = 0.3f;

    //diffuse lighting
    lightVec = normalize(lightVec);
    float diffuse = max(0.0f, dot(vNormal, lightVec));

    // speculat lighting
    float specularLight = 0.5f;
    vec3 viewDirection = normalize(uCamPos - vCrntPos);
    vec3 reflectionDir  = reflect(-lightVec, vNormal);
    float specAmount = pow(max(dot(viewDirection, reflectionDir), 0.0f), 8);
    float specular = specAmount * specularLight;

    return (diffuse * intensity + ambient + specular * intensity);
}

float direcLight() //tous les rayons sont paralelle (= soleil)
{
    //ambient lighting
    float ambient = 0.3f;

    //diffuse lighting
    vec3 lightDir = normalize(-uLightDir); //direction inverse de la lumiere
    float diffuse = max(0.0f, dot(vNormal, lightDir));

    // speculat lighting
    float specularLight = 0.5f;
    vec3 viewDirection = normalize(uCamPos - vCrntPos);
    vec3 reflectionDir  = reflect(-lightDir, vNormal);
    float specAmount = pow(max(dot(viewDirection, reflectionDir), 0.0f), 8);
    float specular = specAmount * specularLight;

    return (diffuse + ambient + specular);
}

float spotLight() // cone de lumière (= projecteur)
{
    float coneInterne = 0.95; //cos(18)
    float coneExterne = 0.90; //cos(25)

    //ambient lighting
    float ambient = 0.3f;

    //diffuse lighting
    vec3 lightVec = normalize(uLightPos - vCrntPos);
    float diffuse = max(0.0f, dot(vNormal, lightVec));

    // speculat lighting
    float specularLight = 0.5f;
    vec3 viewDirection = normalize(uCamPos - vCrntPos);
    vec3 reflectionDir  = reflect(-lightVec, vNormal);
    float specAmount = pow(max(dot(viewDirection, reflectionDir), 0.0f), 8);
    float specular = specAmount * specularLight;

    float angle = dot(uLightDir, -lightVec);
    float intensity = clamp( (angle - coneExterne)/(coneInterne - coneExterne) , 0.0, 1.0);

    return (diffuse * intensity + ambient + specular * intensity);
}

void main()
{
    float intensiteLumineuse = 1.0;
    if (uLightData.x == 1.0){
        intensiteLumineuse = pointLight();
    } else if (uLightData.x == 2.0) {
        intensiteLumineuse = direcLight();
    } else if (uLightData.x == 3.0) {
        intensiteLumineuse = spotLight();
    }
    
    vec3 laCouleur = uColor.xyz * uLightColor * intensiteLumineuse;
    color = vec4(laCouleur, 1.0);
}