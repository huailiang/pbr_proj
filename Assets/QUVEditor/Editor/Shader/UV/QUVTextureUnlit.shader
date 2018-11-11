Shader "Hidden/QTools/QUVTextureUnlit" 
{
	Properties 
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	}
	
	SubShader 
	{
		Tags { "Queue"="Geometry" "RenderType"="Transparent" }
		LOD 200		
		Lighting off
		Cull off
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite off
		
		PASS 
		{
			CGPROGRAM
			#pragma vertex vert
        	#pragma fragment frag
        	#pragma fragmentoption ARB_precision_hint_fastest
        	#include "UnityCG.cginc" 
			
			sampler2D _MainTex;
			float4 _MainTex_ST;	 
			
			struct appdata 
	        {	
	            float4 vertex: POSITION;	
	            fixed4 color : COLOR;	
	            float2 uv	 : TEXCOORD0;		
	        };
			
			struct v2f 
			{				
	            float4 pos   : SV_POSITION;	
	            fixed4 color : COLOR;	
	            float2 uv	 : TEXCOORD0;	
	        };		 	         
		        	
	        v2f vert(appdata v)	
	        {	
	            v2f o;	
	            o.pos = UnityObjectToClipPos(v.vertex);	
	            o.color = v.color; 	            
	            o.uv = TRANSFORM_TEX(v.uv, _MainTex); 
	            return o;	
	        }	

	        fixed4 frag(v2f IN): COLOR	
	        {	
	            return tex2D(_MainTex, IN.uv);
	        }
			
			ENDCG
		}
	}
}
