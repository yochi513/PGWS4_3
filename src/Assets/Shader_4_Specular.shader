Shader "Custom/Material_4_Specular"
{
    Properties
    {
      _SpecularPower("Specular Power",Range(0.001,300))=80
      _SpecularIntensity("Specular Intensity",Range(0,1))=0.3

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
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normal:NORMAL;
                float3 position:TEXCOORDO;
            };
            CBUFFER_START(UnityPerMaterial)
            half _SpecularPower;
                half _SpecularIntensity;
                CBUFFER_END

           
                Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normal=TransformObjectToWorldNormal(IN.normal);
                OUT.position=TransformObjectToWorld(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light light=GetMainLight();
                half3 normal=normalize(IN.normal);
                half3 view_direction=normalize(TransformViewToWorld(float3(0,0,0))-IN.position);
                float3 reflected_direction=-light.direction+2*normal*dot(light.direction,normal);
                
                half3 specular=_SpecularIntensity*pow(max(0,dot(reflected_direction,view_direction)),_SpecularPower);
                
                half3 color=light.color*specular;
                return half4( color,1);
            }
            ENDHLSL
        }
    }
}
