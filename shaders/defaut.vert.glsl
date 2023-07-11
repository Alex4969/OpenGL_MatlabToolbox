#version 450 core

layout(location = 0) in vec3 position;

uniform mat4 uModelMatrix = mat4(1.0);
uniform mat4 uCamMatrix = mat4(1.0);

out DATA
{
	vec3 vCrntPos;
	mat4 vProjection;
} data_out;

void main()
{
    vec4 crntPos = uModelMatrix * vec4(position, 1.0);
    gl_Position = crntPos;

    data_out.vCrntPos = crntPos.xyz;
    data_out.vProjection = uCamMatrix;
};