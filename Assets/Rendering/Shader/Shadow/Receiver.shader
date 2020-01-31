Shader "CustomShadow/Receiver" {
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 300 

        Pass {
            Name "FORWARD"
            Tags{ "LightMode" = "ForwardBase" }

            CGPROGRAM
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 shadowCoord : TEXCOORD0;
            };

            uniform float4x4 _gWorldToShadow;
            uniform sampler2D _gShadowMapTexture;
            uniform float4 _gShadowMapTexture_TexelSize;
            uniform float _gShadowStrength; 
            uniform float _gShadowBias;

            v2f vert (appdata_full v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.shadowCoord = mul(_gWorldToShadow, worldPos);
                return o; 
            }

            float PCFSample(float depth, float2 uv)
            {
                float shadow = 0.0;
                for (int x = -1; x <= 1; ++x)
                {
                    for (int y = -1; y <= 1; ++y)
                    {
                        float4 col = tex2D(_gShadowMapTexture, uv + float2(x, y) * _gShadowMapTexture_TexelSize.xy);
                        float sampleDepth = DecodeFloatRGBA(col);
                        shadow += sampleDepth < depth ? _gShadowStrength : 1;
                    }
                }
                return shadow /= 9;
            }

            fixed4 frag (v2f i) : COLOR0 
            {            
                i.shadowCoord.xy = i.shadowCoord.xy/i.shadowCoord.w;
                float2 uv = i.shadowCoord.xy;
                uv = uv * 0.5 + 0.5; //(-1, 1)-->(0, 1)

                float depth = i.shadowCoord.z / i.shadowCoord.w;
            #if defined (SHADER_TARGET_GLSL)
                depth = depth * 0.5 + 0.5; //(-1, 1)-->(0, 1)
            #elif defined (UNITY_REVERSED_Z)
                depth = 1 - depth;       //(1, 0)-->(0, 1)
            #endif
            
                float4 col = tex2D(_gShadowMapTexture, uv);
                float sampleDepth = DecodeFloatRGBA(col);
                float shadow = sampleDepth < depth + _gShadowBias ? _gShadowStrength : 1;
                // float shadow = PCFSample(depth, uv);
               if(depth >1 && sampleDepth >1) return 1;
                return shadow;
            }    

            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest  
            ENDCG
        }
    }
}