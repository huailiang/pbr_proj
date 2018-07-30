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
    #ifdef LIGHTMAP_ON
        output.ambientOrLightmapUV.xy = input.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        output.ambientOrLightmapUV.zw = 0;
    #elif UNITY_SHOULD_SAMPLE_SH
    #endif
    #ifdef DYNAMICLIGHTMAP_ON
        output.ambientOrLightmapUV.zw = input.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif
    output.normalDir = UnityObjectToWorldNormal(input.normal);
    output.tangentDir = normalize(mul(unity_ObjectToWorld, float4( input.tangent.xyz, 0.0)).xyz);
    output.bitangentDir = normalize(cross(output.normalDir, output.tangentDir) * input.tangent.w);
    output.posWorld = mul(unity_ObjectToWorld, input.vertex);
    float3 lightColor = _LightColor0.rgb;
    output.pos = UnityObjectToClipPos(input.vertex);
    UNITY_TRANSFER_FOG(output,output.pos);
    TRANSFER_VERTEX_TO_FRAGMENT(output)
}

#endif //UNITY_VERT