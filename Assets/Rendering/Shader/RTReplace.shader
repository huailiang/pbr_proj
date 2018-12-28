
Shader "Custom/TexProj" 
{
	Properties 
	{
		_MainTex("Cookie", 2D) = "gray" {}
	  	_Color ("Tint", Color) = (1,1,1,1)
	}

	SubShader 
	{
		Tags {"Queue"="Transparent"}
		Pass {
	   	ZWrite Off
	   	ColorMask RGB
	   	Blend SrcAlpha One
	   	//Offset -1, -1

	   CGPROGRAM
	   #pragma vertex vert
	   #pragma fragment frag
	   #pragma multi_compile_fog
	   #include "UnityCG.cginc"
	   
	   struct v2f {
	    float4 uv0 : TEXCOORD0;
	    UNITY_FOG_COORDS(2)
	    float4 pos : SV_POSITION;
	   };
	   
	   float4x4 unity_Projector;
	   
	   v2f vert (float4 vertex : POSITION)
	   {
	    v2f o;
	    o.pos = UnityObjectToClipPos (vertex); 
	    o.uv0 = mul (unity_Projector, vertex);
	    UNITY_TRANSFER_FOG(o,o.pos);
	    return o;
	   }
	   
	   sampler2D _MainTex;
	   fixed4 _Color;
	   
	   fixed4 frag (v2f i) : SV_Target
	   {
	    fixed4 res = tex2Dproj (_MainTex, UNITY_PROJ_COORD(i.uv0));
	    
	    res = res * _Color;

	    UNITY_APPLY_FOG_COLOR(i.fogCoord, res, fixed4(1,1,1,1));
	    return res;
	   }
	   ENDCG
	  }
	 }

}
