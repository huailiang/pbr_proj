/**
* stdlib.cginc: comon varible and function
*/

#ifndef UNITY_STDLIB
#define UNITY_STDLIB

#include "UnityPBSLighting.cginc"
#include "UnityStandardBRDF.cginc"

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

// Using pow often result to a warning like this
// "pow(f, e) will not work for negative f, use abs(f) or conditionally handle negative values if you expect them"
// PositivePow remove this warning when you know the value is positive and avoid inf/NAN.
inline float PositivePow(float base, float power)
{
    return pow(max(abs(base), float(FLT_EPSILON)), power);
}

inline float2 PositivePow(float2 base, float2 power)
{
    return pow(max(abs(base), float2(FLT_EPSILON, FLT_EPSILON)), power);
}

inline float3 PositivePow(float3 base, float3 power)
{
    return pow(max(abs(base), float3(FLT_EPSILON, FLT_EPSILON, FLT_EPSILON)), power);
}

inline float4 PositivePow(float4 base, float4 power)
{
    return pow(max(abs(base), float4(FLT_EPSILON, FLT_EPSILON, FLT_EPSILON, FLT_EPSILON)), power);
}

#endif //UNITY_STDLIB