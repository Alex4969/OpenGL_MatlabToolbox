out DATA {
	vec3 vCrntPos;
	mat4 vProjection;
    vec2 vTextureCoord; //TEX
    vec4 vColor;        //COL3, COL4
} data_out;

void main() {
    vec3 position3D = vec3(position2D, 0.0);            //POS2
    vec4 crntPos = uModelMatrix * vec4(position3D, 1.0);
    gl_Position = crntPos;

    data_out.vCrntPos = crntPos.xyz;
    data_out.vProjection = uCamMatrix;
    data_out.vColor = color4D;                //COL4
    data_out.vColor = vec4(color3D, 1.0);     //COL3
    data_out.vTextureCoord = textureCoord;  //TEX
}