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
uniform float4 _Properties;

#if USE_SPECIAL_RIM_COLOR
uniform float4 _RimColor;
#endif


#endif //UNITY_MATERIAL