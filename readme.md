<p align="center">
	<a href="https://unity3d.com/cn/">
	    <img src="https://huailiang.github.io/img/unity.jpeg" width="200" height="100">
	</a>
    <a href="https://huailiang.github.io/">
    	<img src="https://huailiang.github.io/img/avatar-Alex.jpg" width="120" height="100">
   	</a>
</p>


PBR 渲染 

以metallic 工作流实现的一套简化的pbs,适合在手机移动平台上running。


Shader调试：

选中Shader, 查看DebugMode

1. None     完整的输出(Specular+Diffuse)
2. Diffuse  漫反射颜色输出
3. Specular 高光颜色计算
4. Normal	法线的输出
5. Rim      边缘发光


区别于官方的pbr shader, 我们在render的时候，可以使用一些自定义的选项。虽然这些效果会让渲染出来的结果打破物理计算出来的结果，但是出于美术或者策划这样或者那样的需求，我们还是这样做了。
比如说，我们在保证基于物理计算的同时，还加入了边缘发光的效果。类似的我们还可以附加其他效果。当然，我们也有开关来控制这样效果的显示。


我们对PBR使用的公式：

由于移动平台的限制，我们只考虑了主光的计算。基于unity5最新的Enlighten系统，我们在计算时考虑到了直接光照和间接光照。

diffuse:

代码如下：

```hlsl
 NdotL = max(0.0,dot(normalDirection, lightDirection));
half fd90 = 0.5 + 2 * LdotH * LdotH * (1-gloss);
float nlPow5 = Pow5(1-NdotL);
float nvPow5 = Pow5(1-NdotV);
float3 directDiffuse = ((1 +(fd90 - 1)*nlPow5) * (1 + (fd90 - 1)*nvPow5) * NdotL) * attenColor;
float3 indirectDiffuse = float3(0,0,0);
indirectDiffuse += gi.indirect.diffuse;
float3 diffuse = (directDiffuse + indirectDiffuse) * diffuseColor;
```


cpecular:

很多BRDF模型里的计算，比如微面元法线分布函数(GGXTerm)、微面元遮挡函数(SmithJointGGXVisibilityTerm)、菲涅耳反射(FresnelTerm), 我们直接使用了UnityStandardBRDF.cginc里已经为我们实现好的函数。

UnityStandardBRDF.cginc放在unity安装目录Editor\Data\CGIncludes下面

```hlsl
   float NdotL = saturate(dot(normalDirection, lightDirection));
    float LdotH = saturate(dot(lightDirection, halfDirection));
    float3 specularColor = _Metallic;
    float specularMonochrome;
    float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(i.uv0, _MainTex));
    float3 diffuseColor = (_MainTex_var.rgb*_Color.rgb); // Need this for specular when using metallic
    diffuseColor = DiffuseAndSpecularFromMetallic(diffuseColor, specularColor, specularColor, specularMonochrome);
    specularMonochrome = 1.0-specularMonochrome;
    float NdotV = abs(dot(normalDirection, viewDirection));
    float NdotH = saturate(dot(normalDirection, halfDirection));
    float VdotH = saturate(dot(viewDirection, halfDirection));
    float visTerm = SmithJointGGXVisibilityTerm(NdotL, NdotV, roughness);
    float normTerm = GGXTerm(NdotH, roughness);
    float specularPBL = (visTerm*normTerm) * PI;
    #ifdef UNITY_COLORSPACE_GAMMA
        specularPBL = sqrt(max(1e-4h, specularPBL));
    #endif
    specularPBL = max(0, specularPBL * NdotL);
    #if defined(_SPECULARHIGHLIGHTS_OFF)
        specularPBL = 0.0;
    #endif
    half surfaceReduction;
    #ifdef UNITY_COLORSPACE_GAMMA
        surfaceReduction = 1.0-0.28*roughness*perceptualRoughness;
    #else
        surfaceReduction = 1.0/(roughness*roughness + 1.0);
    #endif
    specularPBL *= any(specularColor) ? 1.0 : 0.0;
    float3 directSpecular = attenColor*specularPBL*FresnelTerm(specularColor, LdotH);
    half grazingTerm = saturate( gloss + specularMonochrome );
    float3 indirectSpecular = (gi.indirect.specular);
    indirectSpecular *= FresnelLerp (specularColor, grazingTerm, NdotV);
    indirectSpecular *= surfaceReduction;
    float3 specular = (directSpecular + indirectSpecular);
```