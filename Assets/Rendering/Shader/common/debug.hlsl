/**
* debug.hlsl
*/

#ifndef UNITY_DEBUG
#define UNITY_DEBUG

#define Debug_None      1
#define Debug_Diffuse   2
#define Debug_Specular  3
#define Debug_Normal    4
#define Debug_Rim       5


#define DEBUG_PBS_COLOR(diffuse, specular, rim, normal) finalRGBA = DebugOutputColor(diffuse, specular, rim, normal)

uniform float _DebugMode;


float4 DebugOutputColor (float3 diffuse,float3 specular,float3 rim, float3 normal) 
{
    if (_DebugMode<Debug_None)
    {
        return float4(diffuse+specular+rim,1);
    }
    else if (_DebugMode<Debug_Diffuse)
    {
        return float4(diffuse,1);
    }
    else if (_DebugMode<Debug_Specular)
    {
        return float4(specular,1);
    }
    else if (_DebugMode<Debug_Normal)
    {
        return float4(normal,1);
    }
    else if (_DebugMode<Debug_Rim)
    {
        return float4(rim,1);
    }
    return float4(1,1,1,1);
}

#endif //UNITY_DEBUG