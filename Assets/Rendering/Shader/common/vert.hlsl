/**
* vert.hlsl: vert function
*/

#ifndef UNITY_VERT
#define UNITY_VERT

#include "Lighting.cginc"
#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "head.hlsl"
#include "stdlib.hlsl"


void vertPBRForwardBase (VertexPBRInput v,out VertexPBROutput o) {
    INITIALIZE_OUTPUT(VertexPBROutput,o);
    o.uv0 = v.texcoord0;

    o.normalDir = UnityObjectToWorldNormal(v.normal);
    o.tangentDir = normalize(mul(unity_ObjectToWorld, float4( v.tangent.xyz, 0.0)).xyz);
    o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
    o.posWorld = mul(unity_ObjectToWorld, v.vertex);
    float3 lightColor = _LightColor0.rgb;
    o.pos = UnityObjectToClipPos(v.vertex);
    UNITY_TRANSFER_FOG(o,o.pos);
    TRANSFER_VERTEX_TO_FRAGMENT(o);

    #ifdef LIGHTMAP_ON
        o.ambientOrLightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        o.ambientOrLightmapUV.zw = 0;
    #elif UNITY_SHOULD_SAMPLE_SH
        o.ambientOrLightmapUV = 0;
        #ifdef VERTEXLIGHT_ON
            float3 light = Shade4PointLights (
              unity_4LightPosX0, 
              unity_4LightPosY0, 
              unity_4LightPosZ0,
              unity_LightColor[0].rgb, 
              unity_LightColor[1].rgb, 
              unity_LightColor[2].rgb, 
              unity_LightColor[3].rgb,
              unity_4LightAtten0, 
              o.posWorld, 
              o.normalDir );
             o.ambientOrLightmapUV += float4(light,0);
        #endif // VERTEXLIGHT_ON
    #endif
    #ifdef DYNAMICLIGHTMAP_ON
        o.ambientOrLightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif
}

#endif //UNITY_VERT