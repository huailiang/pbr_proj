/**
* debug.hlsl
*/

#ifndef UNITY_DEBUG
#define UNITY_DEBUG

#define Debug_None          1
#define Debug_Diffuse       2
#define Debug_Specular      3
#define Debug_GGX           4
#define Debug_SmithJoint    5
#define Debug_Frenel        6
#define Debug_Normal        7
#define Debug_Rim           8
#define Debug_HitEffect     9

struct DebugData
{
    float3 diffuse;
    float3 specular;
    float GGX;
    float SmithJoint;
    float3 Fresnel;
    float3 rim;
    float3 normal;
    float alpha;
    float4 debugColor;
    float ndotv;
};

#define DEBUG_PBS_COLOR(debugData) finalRGBA = DebugOutputColor(debugData)

uniform float _DebugMode;

float4 DebugOutputColor(DebugData debugData) 
{
    float3 diffuse = debugData.diffuse;
    float3 specular = debugData.specular;
    float ggx = debugData.GGX;
    float smith = debugData.SmithJoint;
    float3 frenel = debugData.Fresnel;
    float3 rim = debugData.rim;
    float3 normal = debugData.normal;
    float a = debugData.alpha;
    float4 debug = debugData.debugColor;

    [branch]
    if (_DebugMode < Debug_None)
    {
        return float4(diffuse+specular+rim,a);
    }
    else if (_DebugMode < Debug_Diffuse)
    {
        return float4(diffuse,a);
    }
    else if (_DebugMode < Debug_Specular)
    {
        return float4(specular,a);
    }
    else if (_DebugMode < Debug_GGX)
    {
        return float4(ggx, ggx, ggx, 1);
    }
    else if (_DebugMode < Debug_SmithJoint)
    {
        return float4(smith,smith,smith,1);
    }
    else if (_DebugMode < Debug_Frenel)
    {
        return float4(frenel,1);
    }
    else if (_DebugMode < Debug_Normal)
    {
        return float4(normal,a);
    }
    else if (_DebugMode < Debug_Rim)
    {
        return float4(rim,a);
    }
    else if (_DebugMode < Debug_HitEffect)
    {
        float3 lighting = float3(0,0,0);
        float4 color = float4(diffuse+specular+rim,a);
        [branch]
        if (debug.a<0.4)
        {
            return color *= debug.rgba;
        }
        else if(debug.a<0.8)
        {
            float ndotv= debugData.ndotv;
            float rim = pow(saturate(1-ndotv),2)*20;
            return color += debug.rgba * rim;
        }
        return color;
    }
    return float4(1,1,1,1);
}

#endif //UNITY_DEBUG