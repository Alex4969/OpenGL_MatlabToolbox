#version 450 core

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

out vec3 vSurfaceNormal;
out vec3 vCrntPos;
out vec4 vColor;

in DATA
{
	vec3 vCrntPos;
    vec4 vColor;
	mat4 vProjection;
} data_in[];

void main()
{
	vec3 v1 = vec3(gl_in[1].gl_Position - gl_in[0].gl_Position);
	vec3 v2 = vec3(gl_in[2].gl_Position - gl_in[1].gl_Position);
	vec3 SurfaceNormal = normalize(cross(v1, v2));

	gl_Position = data_in[0].vProjection * gl_in[0].gl_Position; // (gl_in[0].gl_Position + vec4(SurfaceNormal, 0.0)); => vue �clat�e
	vSurfaceNormal = SurfaceNormal;
	vCrntPos = data_in[0].vCrntPos;
	vColor = data_in[0].vColor;
	EmitVertex();
	
	gl_Position = data_in[1].vProjection * gl_in[1].gl_Position;
	vSurfaceNormal = SurfaceNormal;
	vCrntPos = data_in[1].vCrntPos;
	vColor = data_in[1].vColor;
	EmitVertex();

	gl_Position = data_in[2].vProjection * gl_in[2].gl_Position;
	vSurfaceNormal = SurfaceNormal;
	vCrntPos = data_in[2].vCrntPos;
	vColor = data_in[2].vColor;
	EmitVertex();

	EndPrimitive();
};