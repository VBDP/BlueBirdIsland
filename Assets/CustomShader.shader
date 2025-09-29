Shader "BlueBird/plants"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color   ("Main Color", Color) = (1,1,1,1)

        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5
        _BaseLight ("Base Light", Range(0,1)) = 0.0

        _AOMap ("Ambient Occlusion (R)", 2D) = "white" {}
        _AOIntensity ("AO Intensity (Indirect)", Range(0,1)) = 1.0
        _DirOcclusion ("Directional Occlusion (Direct)", Range(0,1)) = 0.5

        // Parámetros del viento
        _WindStrength ("Wind Strength", Range(0,1)) = 0.2
        _WindSpeed ("Wind Speed", Range(0,10)) = 2.0
        _WindScale ("Wind Scale", Range(0,5)) = 1.0
    }

    SubShader
    {
        Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
        LOD 300

        Cull Off   // 🔥 Siempre desactivado (double sided)
        ZWrite On
        Blend Off

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows addshadow finalcolor:ApplyFinalColor vertex:vert
        #pragma target 3.0
        #pragma multi_compile_fog
        #pragma instancing_options assumeuniformscaling
        #pragma multi_compile _ _DOUBLE_SIDED_GI

        sampler2D _MainTex;
        fixed4 _Color;
        half   _Cutoff;
        half   _BaseLight;

        sampler2D _AOMap;
        half   _AOIntensity;
        half   _DirOcclusion;

        float _WindStrength;
        float _WindSpeed;
        float _WindScale;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_AOMap;
        };

        // 💨 deformación de vértices con viento
        void vert (inout appdata_full v)
        {
            float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

            float wave = sin(worldPos.x * _WindScale + _Time.y * _WindSpeed) *
                         cos(worldPos.z * _WindScale + _Time.y * _WindSpeed);

            v.vertex.x += wave * _WindStrength * 0.1;
            v.vertex.y += wave * _WindStrength * 0.05;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            clip(albedo.a - _Cutoff);

            o.Albedo = albedo.rgb;
            o.Alpha  = 1;
            o.Metallic   = 0;
            o.Smoothness = 0.35;

            fixed aoSample = tex2D(_AOMap, IN.uv_AOMap).r;
            o.Occlusion = lerp(1.0h, aoSample, _AOIntensity);
        }

        void ApplyFinalColor (Input IN, SurfaceOutputStandard o, inout fixed4 col)
        {
            fixed aoSample = tex2D(_AOMap, IN.uv_AOMap).r;
            fixed dirOcc = lerp(1.0h, aoSample, _DirOcclusion);
            col.rgb *= dirOcc;

            fixed3 baseMin = o.Albedo * _BaseLight;
            col.rgb = max(col.rgb, baseMin);
        }
        ENDCG
    }

    FallBack "Transparent/Cutout/VertexLit"
}
