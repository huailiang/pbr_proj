/**
* vert.cginc: vert function
*/

#ifndef UNITY_VERT
#define UNITY_VERT

#include "Lighting.cginc"
#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "head.cginc"

VertexPBROutput vertPBRForwardBase (VertexPBRInput v) {
    VertexPBROutput o = (VertexPBROutput)0;
    o.uv0 = v.texcoord0;
    #ifdef LIGHTMAP_ON
        o.ambientOrLightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        o.ambientOrLightmapUV.zw = 0;
    #elif UNITY_SHOULD_SAMPLE_SH
    #endif
    #ifdef DYNAMICLIGHTMAP_ON
        o.ambientOrLightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif
    o.normalDir = UnityObjectToWorldNormal(v.normal);
    o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
    o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
    o.posWorld = mul(unity_ObjectToWorld, v.vertex);
    float3 lightColor = _LightColor0.rgb;
    o.pos = UnityObjectToClipPos( v.vertex );
    UNITY_TRANSFER_FOG(o,o.pos);
    TRANSFER_VERTEX_TO_FRAGMENT(o)
    return o;
}

#endif //UNITY_VERT