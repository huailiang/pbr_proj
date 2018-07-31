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


void vertPBRForwardBase (VertexPBRInput input,out VertexPBROutput output) {
    INITIALIZE_OUTPUT(VertexPBROutput,output);
    output.uv0 = input.texcoord0;

    output.normalDir = UnityObjectToWorldNormal(input.normal);
    output.tangentDir = normalize(mul(unity_ObjectToWorld, float4( input.tangent.xyz, 0.0)).xyz);
    output.bitangentDir = normalize(cross(output.normalDir, output.tangentDir) * input.tangent.w);
    output.posWorld = mul(unity_ObjectToWorld, input.vertex);
    float3 lightColor = _LightColor0.rgb;
    output.pos = UnityObjectToClipPos(input.vertex);
    UNITY_TRANSFER_FOG(output,output.pos);
    TRANSFER_VERTEX_TO_FRAGMENT(output)

    #ifdef LIGHTMAP_ON
        output.ambientOrLightmapUV.xy = input.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        output.ambientOrLightmapUV.zw = 0;
    #elif UNITY_SHOULD_SAMPLE_SH
        output.ambientOrLightmapUV = 0;
        #ifdef VERTEXLIGHT_ON
            o.ambientOrLightmapUV += Shade4PointLights (
              unity_4LightPosX0, 
              unity_4LightPosY0, 
              unity_4LightPosZ0,
              unity_LightColor[0].rgb, 
              unity_LightColor[1].rgb, 
              unity_LightColor[2].rgb, 
              unity_LightColor[3].rgb,
              unity_4LightAtten0, 
              output.posWorld, 
              output.normalDir );
        #endif // VERTEXLIGHT_ON
    #endif
    #ifdef DYNAMICLIGHTMAP_ON
        output.ambientOrLightmapUV.zw = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif
}

#endif //UNITY_VERT