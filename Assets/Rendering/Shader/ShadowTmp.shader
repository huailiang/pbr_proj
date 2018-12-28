// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Projector/ShadowTmp" 
{
	Properties 
	{
		_Color("Tint Color", Color) = (1,1,1,1)
		_ShadowTex("Cookie", 2D) = "gray" {}
		_Vec("x:shadowhigh   y:shadowfaded",vector)= (0.5,0.5,0.5,0.5)
		_TextureSize ("_TextureSize",Float) = 256
		_BlurRadius ("_BlurRadius",Range(1,15) ) = 1
	}

	Subshader 
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Pass
		{
			Blend  DstColor Zero
		 	ZWrite Off Fog{ Mode Off }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f 
			{
				float4 uvShadow : TEXCOORD0;
				float4 pos : SV_POSITION;
				float4 WSPos : TEXCOORD1;
			};

			float4x4 unity_Projector;

			v2f vert(float4 vertex : POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				o.uvShadow = mul(unity_Projector, vertex);
				o.WSPos = mul(unity_ObjectToWorld,vertex);
				return o;
			}


			sampler2D _ShadowTex;
			fixed4 _Color;
			half4 _Vec;

			float _TextureSize;
			float _BlurRadius;

			float4 GetBlurColor( float4 uvshadow )
			{
			    float space = 1.0/_TextureSize; 
			    int count = _BlurRadius * 2 +1; 
			    count *= count;
			    float4 colorTmp = float4(0,0,0,0);
			    for( int x = -_BlurRadius ; x <= _BlurRadius ; x++ )
			    {
			        for( int y = -_BlurRadius ; y <= _BlurRadius ; y++ )
			        {
						float4 ShadowUV= UNITY_PROJ_COORD(uvshadow);
						ShadowUV.xy += float2(x * space,y * space);
			            fixed4 texCookie01 = tex2Dproj(_ShadowTex, ShadowUV);
			            colorTmp += texCookie01;
			        }
			    }
			    return colorTmp/count;
			}


			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 BlurColor = GetBlurColor(i.uvShadow);
				fixed4 outColor = _Color ;		
				float4 _uvShadow = (i.uvShadow * 2 - 1);
				float high = 1 - saturate(( i.WSPos.y - _Vec.x) * _Vec.y);
				fixed dist = min(1, (1 - saturate(length(_uvShadow.xy))) * 3);
				outColor.a = (BlurColor.r)* dist * high;
				return min(1, lerp(_Color, 1, 1-outColor.a) + 1 - _Color.a);
			}
			ENDCG
		}
	}
}
