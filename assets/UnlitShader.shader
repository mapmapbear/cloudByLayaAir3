Shader3D Start
{
    type:Shader3D,
    name:UnlitShader,
    enableInstancing:true,
    supportReflectionProbe:false,
    uniformMap:{
        u_AlbedoColor: { type: Color, default: [1,1,1,1], block: unlit },
        u_AlbedoTexture: { type: Texture2D },
        u_AlphaTestValue: { type: Float, default: 0.5 },
        u_TilingOffset: { type: Vector4, default:[1, 1, 0, 0], block: unlit },
    },
    shaderPass:[
        {
            pipeline:Forward,
            VS:unlitVS,
            FS:unlitPS
        }
    ]
}
Shader3D End

GLSL Start
#defineGLSL unlitVS

    #define SHADER_NAME UnlitVS

    #include "Camera.glsl";
    #include "Sprite3DVertex.glsl";

    #include "VertexCommon.glsl";
    #include "Color.glsl";

    varying vec4 v_Color;
    varying vec2 v_Texcoord0;

    void main()
    {
        Vertex vertex;
        getVertexParams(vertex);

    #ifdef UV
        v_Texcoord0 = transformUV(vertex.texCoord0, u_TilingOffset);
    #endif // UV

    #if defined(COLOR) && defined(ENABLEVERTEXCOLOR)
        v_Color = gammaToLinear(vertex.vertexColor);
    #endif // COLOR && ENABLEVERTEXCOLOR

        mat4 worldMat = getWorldMatrix();

        vec3 positionWS = (worldMat * vec4(vertex.positionOS, 1.0)).xyz;

        gl_Position = getPositionCS(positionWS);

        gl_Position = remapPositionZ(gl_Position);
    }
#endGLSL

#defineGLSL unlitPS
    #define SHADER_NAME UNLITFS

    #include "Color.glsl";

    #include "Scene.glsl";
    #include "SceneFog.glsl";

    varying vec4 v_Color;
    varying vec2 v_Texcoord0;

    void main()
    {
        vec2 uv = v_Texcoord0;

        vec3 color = u_AlbedoColor.rgb;
        float alpha = u_AlbedoColor.a;
    #ifdef ALBEDOTEXTURE
        vec4 albedoSampler = texture2D(u_AlbedoTexture, uv);

        #ifdef Gamma_u_AlbedoTexture
        albedoSampler = gammaToLinear(albedoSampler);
        #endif // Gamma_u_AlbedoTexture

        color *= albedoSampler.rgb;
        alpha *= albedoSampler.a;
    #endif // ALBEDOTEXTURE

    #if defined(COLOR) && defined(ENABLEVERTEXCOLOR)
        vec4 vertexColor = v_Color;
        color *= vertexColor.rgb;
        alpha *= vertexColor.a;
    #endif

    #ifdef ALPHATEST
        if (alpha < u_AlphaTestValue)
        discard;
    #endif // ALPHATEST

    #ifdef FOG
        color = scenUnlitFog(color);
    #endif // FOG

        gl_FragColor = vec4(color, alpha);
    }
#endGLSL
GLSL End


