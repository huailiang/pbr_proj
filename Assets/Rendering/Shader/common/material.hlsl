/**
* material.hlsl
*/


#ifndef UNITY_MATERIAL
#define UNITY_MATERIAL

uniform float4 _Color;
uniform sampler2D _MainTex; 
uniform float4 _MainTex_ST;
uniform sampler2D _NormalMap; 
uniform float4 _NormalMap_ST;
uniform float _Metallic;
uniform float _Gloss;


struct MaterialData
{
	
};


#endif //UNITY_MATERIAL