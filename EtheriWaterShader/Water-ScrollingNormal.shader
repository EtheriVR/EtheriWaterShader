Shader "Etheri/Water-ScrollingNormal"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalTex("Bump", 2D) = "bump"{}    
        _WaveTex("Wave", 2D) = "bump"{}    
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _ScrollX("X speed", Range(-10, 10)) = 2
        _ScrollY("Y speed", Range(-10, 10)) = 2
        _NormalIntensity("Normal Intensity", Range(0, 10)) = 1
        _WaveIntensity("Wave Intensity", Range(0, 10)) = 1
        _Spin("Swirl", Range(-20, 20)) = 1

        [Toggle(SCROLL_ALBEDO)]_ScrollAlbedo("Scroll Abedo", Float) = 0
        _AlbedoScrollX("X speed albedo", Range(-20, 20)) = 2
        _AlbedoScrollY("Y speed albedo", Range(-20, 20)) = 2


    }
    SubShader
    {
        Tags{"Queue" = "Transparent" "RenderType"="Transparent" }
        LOD 200

        CGPROGRAM

        #pragma surface surf Standard fullforwardshadows alpha:fade
        #pragma target 3.0
        #pragma shader_feature SCROLL_ALBEDO
        
        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalTex;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        sampler2D _NormalTex;
        sampler2D _WaveTex;

        fixed _ScrollX;
        fixed _ScrollY;
        fixed _NormalIntensity;
        fixed _Spin;
        fixed _WaveIntensity;
        fixed _AlbedoScrollX;
        fixed _AlbedoScrollY;
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            #ifdef SCROLL_ALBEDO
                float2 uvScroll = IN.uv_MainTex;
                uvScroll.x += _Time * _AlbedoScrollX;
                uvScroll.y += _Time * _AlbedoScrollY;
                fixed4 c = tex2D (_MainTex, uvScroll) * _Color;
            #else
                fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            #endif

            fixed2 _NormalScroll;

            _NormalScroll.x = _Time * _ScrollX;
            _NormalScroll.y = _Time * _ScrollY;

            float2 scrollSpin;            
            scrollSpin.y = sin(_Time*_Spin);
            scrollSpin.x = cos(_Time*_Spin);

            float2 uvScrollNormal = IN.uv_NormalTex;
            uvScrollNormal += _NormalScroll;

            float3 normalMap = UnpackNormal(tex2D(_NormalTex, uvScrollNormal));
            
            uvScrollNormal += scrollSpin;
            
            float3 waveNormal = UnpackNormal(tex2D(_WaveTex, uvScrollNormal));
            normalMap += waveNormal*_WaveIntensity;

            normalMap.x *= _NormalIntensity;
            normalMap.y *= _NormalIntensity;
            
            o.Normal = normalize(normalMap.rgb);
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness+waveNormal;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}