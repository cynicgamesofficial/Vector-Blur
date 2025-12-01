void main()
{
    vec2 velocity = ViewVelocity * u_velocityScale;
    float velocityMagnitude = length(velocity);
    
    // Early exit for minimal motion
    if (velocityMagnitude < 0.008) {
        FragColor = texture(InputTexture, TexCoord);
        return;
    }
    
    vec2 blurDirection = -normalize(velocity);
    
    vec4 color = vec4(0.0);
    float totalWeight = 0.0;
    
    // 
    float chromaStrength = clamp(velocityMagnitude * 3.0, 0.3, 1.0);
    vec3 chromaOffset = (u_chromaticAberration != 0) ? 
        vec3(-0.0025, 0.0, 0.0025) * chromaStrength : 
        vec3(0.0);
    
    int actualSamples = min(u_samples, 16);
    if (actualSamples <= 1)
    {
        FragColor = texture(InputTexture, TexCoord);
        return;
    }
    
    for (int i = 0; i < 16; i++)
    {
        if (i >= actualSamples) break;
        
        float t = float(i) / float(actualSamples - 1);
        
        // 
        float linearT = t;
        float sqrtT = sqrt(t);
        float distributedT = mix(linearT, sqrtT, 0.6);
        
        // 
        float gaussianFalloff = 2.8;
        float weight = exp(-distributedT * gaussianFalloff);
        
        vec2 offset = blurDirection * (distributedT * velocityMagnitude * u_blurStrength * 0.5);
        vec2 sampleCoord = TexCoord + offset;
        
        // 
        vec2 originalCoord = sampleCoord;
        sampleCoord = clamp(sampleCoord, vec2(0.0), vec2(1.0));
        
        // 
        float edgeDist = max(
            max(0.0 - originalCoord.x, originalCoord.x - 1.0),
            max(0.0 - originalCoord.y, originalCoord.y - 1.0)
        );
        if (edgeDist > 0.0) {
            weight *= exp(-edgeDist * 50.0);
        }
        
        if (u_chromaticAberration != 0) {
            // Scale chromatic offset with sample distance for more natural separation
            vec2 chromaDir = blurDirection * distributedT;
            float r = texture(InputTexture, sampleCoord + chromaOffset.r * chromaDir).r;
            float g = texture(InputTexture, sampleCoord + chromaOffset.g * chromaDir).g;
            float b = texture(InputTexture, sampleCoord + chromaOffset.b * chromaDir).b;
            color += vec4(r, g, b, 1.0) * weight;
        } else {
            color += texture(InputTexture, sampleCoord) * weight;
        }
        
        totalWeight += weight;
    }
    
    color /= totalWeight;
    
    vec4 original = texture(InputTexture, TexCoord);
    
    // 
    float blendFactor = smoothstep(0.005, 0.35, velocityMagnitude);
    blendFactor = clamp(blendFactor * u_blurStrength, 0.0, 0.98);
    
    // 
    vec3 blurred = color.rgb;
    float originalLum = dot(original.rgb, vec3(0.2126, 0.7152, 0.0722)); // Rec. 709 coefficients
    float blurredLum = dot(blurred, vec3(0.2126, 0.7152, 0.0722));
    
    // 
    if (blurredLum > 0.01 && abs(originalLum - blurredLum) > 0.05) {
        float lumRatio = originalLum / blurredLum;
        // Soft clamp to prevent extreme brightening
        lumRatio = clamp(lumRatio, 0.85, 1.15);
        blurred *= lumRatio;
    }
    
    FragColor = vec4(mix(original.rgb, blurred, blendFactor), original.a);
}