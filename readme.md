<p align="center">
	<a href="https://unity3d.com/cn/">
	    <img src="https://huailiang.github.io/img/unity.jpeg" width="200" height="100">
	</a>
    <a href="https://huailiang.github.io/">
    	<img src="https://huailiang.github.io/img/avatar-Alex-home.jpg" width="120" height="100">
   	</a>
</p>


### PBR 渲染 

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

f(l,v)就是PBR的核心内容:

```
// 　　　　　　D(h) F(v,h) G(l,v,h)
//f(l,v) = ---------------------------
// 　　　　　　  4(n·l)(n·v)
```

其中：

微面元法线分布函数 D(h):GGX  

```
//  　　		alpha^2
//D(m) = -------------------------------
//  　　	pi*((n·m)^2 *(alpha^2-1)+1)^2
```
alpha = roughness * roughness,roughness是粗糙度，roughness= 1-smoothness


微面元遮挡函数 G(l,v,h):Smith-Schlick,在Smith近似下G(l,v,h) = g(l)*g(v)


```
//  　　	     n·v
//g(v) =  ------------------
// 　　　　(n·v) *(1-k) +k
```

F(v,h):UE4对Schlick的一个近似

```
//Schlick
//F(v,h) = F0 +(1-F0)*(1-(v·h))^5
//
//UE4 approximation
//
//F(v,h) = F0+(1-F0)2^((-5.55473(v·h)-6.98316)*v·h)
```

UnityStandardBRDF.cginc放在unity安装目录Editor\Data\CGIncludes下面




## 染色

<br><img src='image/dye.gif' align="left" width=1200><br><br>


通过Rendering/Art/Example_ROLE 这个scene查看效果。


染色系统的实现不再基于对纹理简单的采样, 而是程序里自定义颜色。shader的属性里设置了R,G,B 三个通道的颜色，可以通过材质Inspector窗口自定义颜色。piexl shader中去混合这些颜色。


使用这套染色系统，对mesh有一定的要求，需要诸如衣服颜色这些固定颜色的部位使用R,G,B中的一种颜色，里面只有灰度变化。对于像皮肤肉色这种变化的且追求细节的部位，纹理绑定的uv区间需要超出1，


读者感兴趣的话，可以通过工具QUVEditor uv工具查看。unity的QUVEditor可以在[这里][i1]下载。


<br><img src='image/de2.jpg' width=1150><br>


[i1]:http://www.qtoolsdevelop.com/
