/**
* stdlib.cginc: comon varible and function
*/

#ifndef UNITY_STDLIB
#define UNITY_STDLIB

#define EPSILON      1.0e-4
#define PI           3.14159265359
#define INV_PI       0.31830988618
#define HALF_PI      1.57079632679


#define FLT_EPSILON     1.192092896e-07 // Smallest positive number, such that 1.0 + FLT_EPSILON != 1.0
#define FLT_MIN         1.175494351e-38 // Minimum representable positive FLOATing-point number
#define FLT_MAX         3.402823466e+38 // Maximum representable FLOATing-point number

#if defined(SHADER_API_D3D11) || defined(SHADER_API_D3D12) || defined(SHADER_API_VULKAN)|| defined(SHADER_API_METAL)|| defined(SHADER_API_GLES3)
#define INITIALIZE_OUTPUT(type,name) name = (type)0;
#define DECLARE_OUTPUT(type,name) type name;INITIALIZE_OUTPUT(type,name)
#else
#define INITIALIZE_OUTPUT(type,name)
#define DECLARE_OUTPUT(type,name) type name;
#endif

#define swap(a, b)   temp = a; a = min(a, b); b = max(temp, b);

// https://twitter.com/SebAaltonen/status/878250919879639040
// madd_sat + madd
inline float FastSign(float x)
{
    return saturate(x * FLT_MAX + 0.5) * 2.0 - 1.0;
}

inline float2 FastSign(float2 x)
{
    return saturate(x * FLT_MAX + 0.5) * 2.0 - 1.0;
}

inline float3 FastSign(float3 x)
{
    return saturate(x * FLT_MAX + 0.5) * 2.0 - 1.0;
}

inline float4 FastSign(float4 x)
{
    return saturate(x * FLT_MAX + 0.5) * 2.0 - 1.0;
}

#endif //UNITY_STDLIB