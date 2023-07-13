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
    vec3 lightDir = normalize(-lightDirection); //direction inverse de la lumiere
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
// cone de lumière (= projecteur)
{
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