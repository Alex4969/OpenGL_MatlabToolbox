out	vec3 vCrntPos;
out vec3 vNormal;
out vec4 vColor;        //COL3, COL4
out vec2 vTextureCoord; //TEX

void main()
{
    vec3 position3D = vec3(position2D, 0.0);            //POS2
    vec4 crntPos = uModelMatrix * vec4(position3D, 1.0);
    gl_Position = uCamMatrix * crntPos;

    vCrntPos = crntPos.xyz;
    mat3 rotation = mat3(uModelMatrix);
    vNormal = rotation * normal;
    vColor = vec4(color3D, 1.0);        //COL3
    vColor = color4D;                   //COL4
    vTextureCoord = textureCoord;       //TEX
}