# Cynic Games Vector Blur v1.1

Motion blur effect for GZDoom that actually works. Uses proper velocity tracking so it only blurs when you're actually moving, not when you're just pressing keys against a wall.

## Installation

Just drag the PK3 file into GZDoom or load it from the command line. That's it. Works with most mods, though it might conflict with other post-processing effects if they're using the same shader stage.

Requires GZDoom 4.7.0 or newer and a GPU with OpenGL 3.3+ support.

## How to Use

The mod comes with 5 presets you can switch between using the `cynic_blur_preset` console variable (0-4, plus custom at 5). Or just tweak the settings manually to your liking.

**Basic commands:**

```
cynic_blur_enabled true/false          - Turn it on/off
cynic_blur_strength 0.0-1.0            - How strong the blur is (default 0.7)
cynic_blur_samples 4-16                - More samples = better quality but slower (default 10)
cynic_blur_velocity_scale 0.1-3.0      - How sensitive it is to movement (default 1.2)
cynic_blur_chromatic true/false        - Adds color separation for a lens effect (default on)
cynic_blur_preset 0-5                  - Switch between presets
```

**Presets:**
- 0 = Subtle (good for slower systems)
- 1 = Balanced (default, what most people will want)
- 2 = Strong
- 3 = Extreme
- 4 = Max speed
- 5 = Custom (save your own with the save trigger)

To save your current settings as custom preset: `cynic_blur_savecustom_trigger 1` then set preset to 5.

## Settings Guide

**Strength** controls how much blur happens overall. Lower values (0.3-0.5) are more subtle, higher (0.8-1.0) gets really intense. I usually keep it around 0.7.

**Samples** affects quality and performance. More samples means smoother blur but slower. If your framerate drops, try 6-8 instead of the default 10. 4 is the bare minimum that still looks decent.

**Velocity Scale** determines how much movement triggers blur. Lower values (0.5-0.8) make it less sensitive, higher (1.5-2.5) makes it react more to small movements. Useful if you find the default too sensitive or not sensitive enough.

**Chromatic** adds RGB separation at the edges of the blur, like you'd see through a camera lens. Looks cool but adds a tiny bit of overhead. You can turn it off if you want pure motion blur.

## Performance Tips

If it's causing slowdowns:
- Lower the samples (try 6-8)
- Turn off chromatic aberration
- Drop strength to 0.5 or lower
- Reduce velocity scale if you don't need it super sensitive

On faster systems you can crank samples up to 14-16 for really smooth blur, but honestly 10 is usually fine.

## Troubleshooting

**Can't see any blur?**
- Make sure `cynic_blur_enabled` is set to true
- Try bumping velocity_scale up a bit (like 1.5-2.0)
- Check the console for any shader errors

**Blur is too strong/messy?**
- Lower strength to 0.4-0.5
- Reduce velocity_scale to 0.8-1.0
- Turn off chromatic if it's distracting

**Getting stuck on walls triggers blur?**
Shouldn't happen anymore in v1.1 - fixed that issue where pressing keys while stuck would still blur. If it does, let me know.

## File Structure

```
Cynic-Blur.pk3/
├── CVARINFO                    - Console variables
├── gldefs.txt                  - Shader definitions
├── zscript.zs                  - Main script entry
├── shaders/glsl/
│   └── motionblur.fp           - The actual blur shader
└── zscript/
    └── motionblur_handler.zs   - Movement tracking code
```

That's pretty much it. The shader does the visual work, the ZScript handles tracking your movement and passing the data to it.

## Notes

This version fixes the wall-stuck blur bug. Now it checks if you're actually moving before applying blur, not just if you're pressing movement keys. The velocity tracking is position-based so it knows the difference between trying to move and actually moving.

If you run into issues or have suggestions, feel free to let me know. Enjoy the blur!

