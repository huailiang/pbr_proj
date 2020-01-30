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

            fixed4 frag (v2f i) : COLOR0 
            {            
                i.shadowCoord.xy = i.shadowCoord.xy/i.shadowCoord.w;
                float2 uv = i.shadowCoord.xy;
                uv = uv*0.5 + 0.5; //(-1, 1)-->(0, 1)

                float depth = i.shadowCoord.z / i.shadowCoord.w;
            #if defined (SHADER_TARGET_GLSL)
                depth = depth*0.5 + 0.5; //(-1, 1)-->(0, 1)
            #elif defined (UNITY_REVERSED_Z)
                depth = 1 - depth;       //(1, 0)-->(0, 1)
            #endif

                // if(uv.x <=0 || uv.y<=0) return 1;
                // if(uv.x >=1 || uv.y>=1) return 1;
            
                float4 col = tex2D(_gShadowMapTexture, uv);
                float sampleDepth = DecodeFloatRGBA(col);
                float shadow = sampleDepth < depth ? _gShadowStrength : 1;

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