Shader "Hidden/QTools/QUVSceneVertex" 
{
	Properties 
	{
	}
	
	SubShader 
	{
		Tags { "IgnoreProjector"="True" "Queue"="Overlay" "RenderType"="Transparent" }
		LOD 200		
		Lighting off		
		Blend SrcAlpha OneMinusSrcAlpha		
		Cull off
		
		PASS 
		{		
			CGPROGRAM
			#pragma vertex vert
        	#pragma fragment frag
			
			struct appdata 
	        {	
	            float4 vertex: POSITION;	
	            fixed4 color : COLOR;	
	        };
			
			struct v2f 
			{				
	            float4 pos   : SV_POSITION;	
	            fixed4 color : COLOR;		
	        };		 	         
		        	
	        v2f vert(appdata v)	
	        {	
	            v2f o;	

	            o.pos = mul(UNITY_MATRIX_MV, v.vertex);
				o.pos.xyz *= .99;
				o.pos = mul(UNITY_MATRIX_P, o.pos);	            				
				
	            o.color = v.color; 
	            return o;	
	        }	

	        fixed4 frag(v2f IN): COLOR	
	        {		        	        	
	            return IN.color;
	        }
			
			ENDCG
		}
	}
}
