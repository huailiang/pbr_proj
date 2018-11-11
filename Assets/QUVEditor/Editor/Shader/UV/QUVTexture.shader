Shader "Hidden/QTools/QUVTexture" 
{
	Properties 
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Alpha   ("Alpha", float) = 1.0
		_MainTexST("MainTexST", Vector) = ( 1.0, 1.0, 0.0, 0.0 )
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
			float _Alpha;
						
			float4 _MainTexST;	 
			
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
	            o.uv = _MainTexST.xy + v.uv.xy *_MainTexST.zw;
	            return o;
	        }	

	        fixed4 frag(v2f IN): COLOR	
	        {	
	        	fixed4 mainTex = tex2D(_MainTex, IN.uv);
	        		   mainTex.a *= _Alpha;
	            return mainTex;
	        }
			
			ENDCG
		}
	}
}
