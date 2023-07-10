#version 450 core

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

out vec3 v_normal;

void main()
{
	vec3 v1 = vec3(gl_in[1].gl_Position - gl_in[0].gl_Position);
	vec3 v2 = vec3(gl_in[2].gl_Position - gl_in[1].gl_Position);
	vec3 SurfaceNormal = normalize(cross(v1, v2));

	gl_Position = gl_in[0].gl_Position;
	v_normal = SurfaceNormal;
	EmitVertex();
	
	gl_Position = gl_in[1].gl_Position;
	v_normal = SurfaceNormal;
	EmitVertex();

	gl_Position = gl_in[2].gl_Position;
	v_normal = SurfaceNormal;
	EmitVertex();
};