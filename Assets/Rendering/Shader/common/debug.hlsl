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


#define DEBUG_PBS_COLOR(diffuse, specular, rim, normal,alpha) finalRGBA = DebugOutputColor(diffuse, specular, rim, normal, alpha)

uniform float _DebugMode;


float4 DebugOutputColor (float3 diffuse,float3 specular,float3 rim, float3 normal,float a) 
{
    if (_DebugMode<Debug_None)
    {
        return float4(diffuse+specular+rim,a);
    }
    else if (_DebugMode<Debug_Diffuse)
    {
        return float4(diffuse,a);
    }
    else if (_DebugMode<Debug_Specular)
    {
        return float4(specular,a);
    }
    else if (_DebugMode<Debug_Normal)
    {
        return float4(normal,a);
    }
    else if (_DebugMode<Debug_Rim)
    {
        return float4(rim,a);
    }
    return float4(1,1,1,1);
}

#endif //UNITY_DEBUG