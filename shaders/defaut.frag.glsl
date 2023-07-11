#version 450 core

out vec4 color;

in vec3 vSurfaceNormal;
in vec3 vCrntPos;

uniform vec4 uColor;
uniform vec3 uLightColor = vec3(1.0, 1.0, 1.0);
uniform vec3 uLightPos = vec3(2.0, 2.0, 2.0);

void main()
{
    float ambient = 0.3f;
    vec3 lightDir = normalize(uLightPos - vCrntPos);
    
    float diffuse = max(0.0f, dot(vSurfaceNormal, lightDir));

    vec3 interColor = uColor.xyz * uLightColor * (diffuse + ambient);
    color = vec4(interColor, uColor.w);
};