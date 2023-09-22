#version 450 core

layout (triangles) in;
layout (triangle_strip, max_vertices = 3) out;

uniform mat4 uCamMatrix = mat4(1.0);

out vec3 vNormal;
out vec3 vCrntPos;
out vec2 vTextureCoord;  /*CHOIX : TEX */
out vec4 vColor;         /*CHOIX : COL3 COL4 */
out vec2 interpolation;

in DATA
{
	vec3 vCrntPos;
    vec2 vTextureCoord; /*CHOIX : TEX */
    vec4 vColor;        /*CHOIX : COL3 COL4 */
	vec3 vNormal;       /*CHOIX : NORM */
} data_in[];

void main()
{
	vec3 v1 = vec3(gl_in[1].gl_Position - gl_in[0].gl_Position); /*CHOIX : TEX COL3 COL4 DEF */
	vec3 v2 = vec3(gl_in[2].gl_Position - gl_in[1].gl_Position); /*CHOIX : TEX COL3 COL4 DEF */
	vec3 SurfaceNormal = cross(v1, v2);							 /*CHOIX : TEX COL3 COL4 DEF */

	gl_Position = uCamMatrix * gl_in[0].gl_Position;
	vNormal = SurfaceNormal;					/*CHOIX : TEX COL3 COL4 DEF */
	vNormal = data_in[0].vNormal;				/*CHOIX : NORM */
	vCrntPos = data_in[0].vCrntPos;
	vTextureCoord = data_in[0].vTextureCoord;   /*CHOIX : TEX */
	vColor = data_in[0].vColor;					/*CHOIX : COL3 COL4 */
	interpolation = vec2(1.0, 0.0);
	EmitVertex();
	
	gl_Position = uCamMatrix * gl_in[1].gl_Position;
	vNormal = SurfaceNormal;					/*CHOIX : TEX COL3 COL4 DEF */
	vNormal = data_in[1].vNormal;				/*CHOIX : NORM */
	vCrntPos = data_in[1].vCrntPos;
	vTextureCoord = data_in[1].vTextureCoord;   /*CHOIX : TEX */
	vColor = data_in[1].vColor;					/*CHOIX : COL3 COL4 */
	interpolation = vec2(0.0, 1.0);
	EmitVertex();

	gl_Position = uCamMatrix * gl_in[2].gl_Position;
	vNormal = SurfaceNormal;					/*CHOIX : TEX COL3 COL4 DEF */
	vNormal = data_in[2].vNormal;				/*CHOIX : NORM */
	vCrntPos = data_in[2].vCrntPos;
	vTextureCoord = data_in[2].vTextureCoord;   /*CHOIX : TEX */
	vColor = data_in[2].vColor;					/*CHOIX : COL3 COL4 */
	interpolation = vec2(0.0, 0.0);
	EmitVertex();

	EndPrimitive();
};