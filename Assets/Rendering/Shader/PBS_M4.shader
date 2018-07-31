Shader "Custom/PBR/PBR_M4" {
    Properties {        
        _MainTex ("Base Color", 2D) = "white" {}
        _Color ("Color", Color) = (0.0,0.0,0.0,1)
        _NormalMap ("Normal Map", 2D) = "bump" {}
        
        [F4Vector(Metallic,0,1,Gloss,0,1,RimIntensity,0,100,RimWitdh,0,1)]
        _Properties("Properties", Vector) = (0,0,0,1.0)

        [HideInInspector] 
        _DebugMode("debugMode", float) = 0.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        Pass {
            Name "FORWARD"
            Tags { "LightMode"="ForwardBase" }
             
            CGPROGRAM
            
            #pragma target 3.0
            
            #pragma shader_feature OPEN_SHADER_DEBUG
            #define UNITY_PASS_FORWARDBASE
            #define SHOULD_SAMPLE_SH ( defined (LIGHTMAP_OFF) && defined(DYNAMICLIGHTMAP_OFF) )
            #define _GLOSSYENV 1
            
            #include "common/vert.hlsl"
            #include "common/piexl.hlsl"
            #pragma vertex vertPBRForwardBase
            #pragma fragment fragPBRForwardBase

            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
            #pragma multi_compile DIRLIGHTMAP_OFF DIRLIGHTMAP_COMBINED DIRLIGHTMAP_SEPARATE
            #pragma multi_compile DYNAMICLIGHTMAP_OFF DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog
            ENDCG
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{ "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            #include "UnityStandardShadow.cginc"
            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "PBRShaderGUI"
}
