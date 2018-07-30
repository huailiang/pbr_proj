/**
* head.hlsl
*/

#ifndef UNITY_HEAD
#define UNITY_HEAD

struct VertexPBRInput {
    float2 texcoord0 : TEXCOORD0;
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
};

struct VertexPBROutput {
    float4 pos : SV_POSITION;
    float2 uv0 : TEXCOORD0;
    float4 posWorld : TEXCOORD1;
    float3 normalDir : TEXCOORD2;
    float3 tangentDir : TEXCOORD3;
    float3 bitangentDir : TEXCOORD4;
    LIGHTING_COORDS(5,6)
    UNITY_FOG_COORDS(7)
    #if defined(LIGHTMAP_ON) || defined(UNITY_SHOULD_SAMPLE_SH)
        float4 ambientOrLightmapUV : TEXCOORD8;
    #endif
};


#endif //UNITY_HEAD