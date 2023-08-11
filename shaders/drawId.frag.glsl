#version 450 core

out int fragColor;

layout(location = 0) uniform int id;

void main()
{
	fragColor = id;
};