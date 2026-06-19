struct VSInput {
    float2 position : POSITION;
    float2 texcoord : TEXCOORD0;
};

struct PSInput {
    float4 position : SV_POSITION;
    float2 texcoord : TEXCOORD0;
};

// Texture and Sampler
Texture2D mainTexture : register(t0);
SamplerState mainSampler : register(s1);

PSInput VSMain(uint id : SV_VertexID) {
    PSInput output;
    output.texcoord = float2((id << 1) & 2, id & 2);
    output.position = float4(output.texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
    return output;
}

float4 PSMain(PSInput input) : SV_TARGET {
    return mainTexture.Sample(mainSampler, input.texcoord);
}
