#version 450 core

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

out vec3 vNormal;
out vec3 vCrntPos;
out vec2 vTextureCoord;  //TEX
out vec4 vColor;         //COL3 COL4

in DATA
{
	vec3 vCrntPos;
	mat4 vProjection;
    vec2 vTextureCoord; //TEX
    vec4 vColor;        //COL3 COL4
} data_in[];

void main()
{
	vec3 v1 = vec3(gl_in[1].gl_Position - gl_in[0].gl_Position);
	vec3 v2 = vec3(gl_in[2].gl_Position - gl_in[1].gl_Position);
	vec3 SurfaceNormal = cross(v1, v2);

	gl_Position = data_in[0].vProjection * gl_in[0].gl_Position;
	vNormal = SurfaceNormal;
	vCrntPos = data_in[0].vCrntPos;
	vTextureCoord = data_in[0].vTextureCoord; //TEX
	vColor = data_in[0].vColor; //COL3 COL4
	EmitVertex();
	
	gl_Position = data_in[1].vProjection * gl_in[1].gl_Position;
	vNormal = SurfaceNormal;
	vCrntPos = data_in[1].vCrntPos;
	vTextureCoord = data_in[1].vTextureCoord; //TEX
	vColor = data_in[1].vColor; //COL3 COL4
	EmitVertex();

	gl_Position = data_in[2].vProjection * gl_in[2].gl_Position;
	vNormal = SurfaceNormal;
	vCrntPos = data_in[2].vCrntPos;
	vTextureCoord = data_in[2].vTextureCoord;  //TEX
	vColor = data_in[2].vColor; //COL3 COL4
	EmitVertex();

	EndPrimitive();
};