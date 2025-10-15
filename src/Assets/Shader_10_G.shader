Shader "Custom/Shader_10_G"
{
    Properties
    {
      
         [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
         _AmbientRate("Ambient Rate",Range(0,1))=0.2
      _SpecularPower("Specular Power",Range(0.001,300))=80
      _SpecularIntensity("Specular Intensity",Range(0,1))=0.3
      _RoughnessX("Roughness X",Range(0,1))=0.8
        _RoughnessY("Roughness Y",Range(0,1))=0.2
      _Metallic("Metallic",Range(0,1))=0.5
      _SpecularColor("Specular Color", Color) = (1,1,1,1) 
    _Fresnel0("Fresnel0",Range(0,0.99999))=0.8

    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float3 position:TEXCOORDO;
            };
            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half _AmbientRate;
                half _SpecularPower;
                half _SpecularIntensity;
                half _RoughnessX;
                half _RoughnessY;
                half _Metallic;
                half4 _SpecularColor;
                half _Fresnel0;
                CBUFFER_END

           
                Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normal=TransformObjectToWorldNormal(IN.normal);
                OUT.tangent=float4(TransformObjectToWorldNormal(float3(IN.tangent.xyz)).xyz,IN.tangent.w);
                OUT.position=TransformObjectToWorld(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light light=GetMainLight();
                half3 normal=normalize(IN.normal);
                half3 view_direction=normalize(TransformViewToWorld(float3(0,0,0))-IN.position);
                float3 half_vector=normalize(view_direction+ light.direction );

                half VdotN=max(0,dot(view_direction,normal));
                half LdotN=max(0,dot(light.direction,normal));
                half HdotN=max(0,dot(half_vector,normal));
                half LdotH=max(0,dot(half_vector,light.direction));
                half VdotH =max(0,dot(half_vector,view_direction));
              
               half G=min(1,2*min(HdotN*VdotN/VdotH,HdotN*LdotN/LdotH));
              
                half3 color=G;
                return half4( color,1);
            }
            ENDHLSL
        }
    }
}