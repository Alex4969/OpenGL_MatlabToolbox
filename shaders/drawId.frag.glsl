#version 450 core

out uvec3 fragColor;

layout(location = 0) uniform uint id;

void main()
{
	fragColor = uvec3(id, 0, 0);
};