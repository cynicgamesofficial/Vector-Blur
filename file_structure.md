# Cynic Vector Blur V1.1 - Complete File Structure

```
Cynic-Blur.pk3/
│
├── CVARINFO                          # Console variable definitions
├── gldefs.txt                        # Shader declarations
├── zscript.zs                        # ZScript entry point
│
├── shaders/
│   └── glsl/
│       └── motionblur.fp             # Main directional blur shader
│
└── zscript/
    └── motionblur_handler.zs         # Velocity tracking and shader data passing
```

## Installation Instructions

1. **Create the directory structure** as shown above
2. **Add all files** to their respective locations
3. **Package as PK3** (ZIP with .pk3 extension)
4. **Load in GZDoom** via command line or drag-and-drop

## Console Commands

Once loaded, use these commands to customize the effect:

```
cynic_blur_enabled <true/false>           // Toggle effect on/off
cynic_blur_strength <0.0-1.0>             // Blur intensity
cynic_blur_samples <4-16>                 // Quality/performance balance
cynic_blur_velocity_scale <0.1-3.0>       // Sensitivity to movement
cynic_blur_chromatic <true/false>         // Color separation effect
```

## Recommended Presets

**Performance (Low-end PCs):**
```
cynic_blur_samples 4
cynic_blur_strength 0.4
cynic_blur_chromatic false
```

**Balanced (Default):**
```
cynic_blur_samples 8
cynic_blur_strength 0.5
cynic_blur_chromatic true
```

**Quality (High-end PCs):**
```
cynic_blur_samples 16
cynic_blur_strength 0.7
cynic_blur_chromatic true
cynic_blur_velocity_scale 1.2
```

**Extreme Speed Effect:**
```
cynic_blur_samples 12
cynic_blur_strength 0.9
cynic_blur_chromatic true
cynic_blur_velocity_scale 2.0
```

## Technical Details

- **Velocity Tracking**: Captures player movement and camera rotation each tic
- **Smoothing**: Applies exponential moving average to prevent jitter
- **Directional Blur**: Samples along movement vector for realistic motion streaks
- **Chromatic Aberration**: Optional RGB channel separation for lens distortion effect
- **Adaptive Intensity**: Blur scales with velocity magnitude automatically

## Troubleshooting

**No blur effect visible:**
- Ensure `cynic_blur_enabled true`
- Try increasing `cynic_blur_velocity_scale`
- Check GZDoom console for shader compilation errors

**Performance issues:**
- Lower `cynic_blur_samples` to 4-6
- Disable chromatic aberration
- Reduce `cynic_blur_strength`

**Blur too strong:**
- Reduce `cynic_blur_strength` to 0.3-0.4
- Lower `cynic_blur_velocity_scale` to 0.5-0.7

## Compatibility

- **Requires**: GZDoom 4.7.0 or newer
- **OpenGL Version**: 3.3+ (for shader support)
- **Compatible with**: Most gameplay mods, other visual effects
- **May conflict with**: Other post-processing shaders in `beforebloom` stage
