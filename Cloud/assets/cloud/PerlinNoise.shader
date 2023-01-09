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
        u_freq: {type: Float, default: 0.5, range:[0.0, 10.0]},
        u_octaves: {type: Float, default: 0.5, range:[0.0, 10.0]},
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

    #include "Color.glsl";

    #include "Scene.glsl";
    #include "Camera.glsl";
    #include "Sprite3DVertex.glsl";

    #include "VertexCommon.glsl";

    #include "BlinnPhongVertex.glsl";

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
        PixelParams pixel;
        initPixelParams(pixel, vertex);
        // vec3 posOS = vec3(perlinfbm(vertex.positionOS.xyz, u_freq, u_octaves), perlinfbm(vertex.positionOS.xyz, u_freq, u_octaves), perlinfbm(vertex.positionOS.xyz, u_freq, u_octaves));
        vec3 positionWS = (worldMat * vec4(vertex.positionOS, 1.0)).xyz;

        gl_Position = getPositionCS(positionWS);

        gl_Position = remapPositionZ(gl_Position);
    }
#endGLSL

#defineGLSL unlitPS
    #define SHADER_NAME UNLITFS

    #include "Color.glsl";
    #include "Scene.glsl";
    #include "Camera.glsl";
    #include "PBRMetallicFrag.glsl"
    #include "SceneFog.glsl";

    #define UI0 1597334673U
    #define UI1 3812015801U
    #define UI2 uvec2(UI0, UI1)
    #define UI3 uvec3(UI0, UI1, 2798796415U)
    #define UIF (1.0 / float(0xffffffffU))
    vec3 hash33(vec3 p)
    {
        uvec3 q = uvec3(ivec3(p)) * UI3;
        q = (q.x ^ q.y ^ q.z) * UI3;
        return -1. + 2. * vec3(q) * UIF;
    }


    // 晶格噪声(输入, 频率)
    float gradientNoise(vec3 x, float freq) 
    {
        vec3 p = floor(x);
        vec3 w = fract(x);
        vec3 u = w * w * w * (w * (w * 6. - 15.) + 10.);
        vec3 ga = hash33(mod(p + vec3(0., 0., 0.), freq));
        vec3 gb = hash33(mod(p + vec3(1., 0., 0.), freq));
        vec3 gc = hash33(mod(p + vec3(0., 1., 0.), freq));
        vec3 gd = hash33(mod(p + vec3(1., 1., 0.), freq));
        vec3 ge = hash33(mod(p + vec3(0., 0., 1.), freq));
        vec3 gf = hash33(mod(p + vec3(1., 0., 1.), freq));
        vec3 gg = hash33(mod(p + vec3(0., 1., 1.), freq));
        vec3 gh = hash33(mod(p + vec3(1., 1., 1.), freq));

        float va = dot(ga, w - vec3(0., 0., 0.));
        float vb = dot(gb, w - vec3(1., 0., 0.));
        float vc = dot(gc, w - vec3(0., 1., 0.));
        float vd = dot(gd, w - vec3(1., 1., 0.));
        float ve = dot(ge, w - vec3(0., 0., 1.));
        float vf = dot(gf, w - vec3(1., 0., 1.));
        float vg = dot(gg, w - vec3(0., 1., 1.));
        float vh = dot(gh, w - vec3(1., 1., 1.));

        return va + u.x * (vb - va) + u.y * (vc - va) + u.z * (ve - va) + u.x * u.y * (va - vb - vc + vd) + u.y * u.z * (va - vc - ve + vg) + u.z * u.x * (va - vb - ve + vf) + u.x * u.y * u.z * (-va + vb + vc - vd + ve - vf - vg + vh);
    }

    //分形布朗运动(Fractal Brownian Motion)
    //柏林FBM，其中p为采样点坐标，freq为频率，octaves为要增加的八度
    float perlinfbm(vec3 p, float freq, float octaves)
    {
        //exp2(x)表示2的x次方，该项为赫斯特指数
        float G = exp2(-.85);
        //一开始的赫斯特指数影响系数为1
        float amp = 1.;
        //一开始的噪音值为0
        float noise = 0.;
        //进行噪音叠加循环，其中octaves为要增加几个八度
        int numOctaves =  int(floor(octaves));
        for (int i = 0; i < numOctaves; ++i)
        {
            //采样晶格噪音，并乘上赫斯特指数影响系数，并进行噪音叠加
            noise += amp * gradientNoise(p * freq, freq);
            //提高频率
            freq *= 2.;
            //更新影响系数
            amp *= G;
        }
        //返回叠加结果
        return noise;
    }

    float worleyNoise(vec3 uv, float freq)
    {
        vec3 id = floor(uv);

        vec3 p = fract(uv);

        float minDist = 1e4;
        for(float x = -1.0; x <= 1.0; ++x)
        {
            for(float y = -1.0; y <= 1.0; ++y) {
                for(float z = -1.0; z <= 1.0; ++z) {
                    vec3 offset = vec3(x, y, z);
                    vec3 h = hash33(mod(id + offset, vec3(freq))) * .5 + .5;
                    h += offset;
                    vec3 d = p - h; // distance vector
                    minDist = min(minDist, dot(d, d));
                }
            }
        }

        return minDist;
    }

    float worleyFbm(vec3 p, float freq)
    {
        return 
        worleyNoise(p * freq, freq) * .625 + //原频率×权重
        worleyNoise(p * freq * 2., freq * 2.) * .25 + //二倍频率×权重
        worleyNoise(p * freq * 4., freq * 4.) * .125; //四倍频率×权重
    }

    void main()
    {
        PixelParams pixel;
        getPixelParams(pixel);

        vec3 inXYZ = vec3(pixel.positionWS.xyz);
        // float noiseValue = gradientNoise(inXYZ, u_freq);
        // float noiseValue = perlinfbm(inXYZ, u_freq, u_octaves);
        // float noiseValue = worleyNoise(inXYZ, u_freq);
        float noiseValue = worleyFbm(inXYZ, u_freq);

        gl_FragColor = vec4(noiseValue, noiseValue, noiseValue, 1.0);
    }
#endGLSL
GLSL End


