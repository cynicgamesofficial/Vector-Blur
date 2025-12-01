class CynicMotionBlurHandler : StaticEventHandler
{
    private int pitch, yaw;
    
    private double xtravel, ytravel;
    
    private Vector3 prevPos;
    private double prevYaw, prevPitch;
    private bool initialized;
    
    private int lastPreset;
    private bool presetInitialized;
    
    private transient CVar cvar_blurStrength;
    private transient CVar cvar_samples;
    private transient CVar cvar_velocityScale;
    private transient CVar cvar_chromatic;
    private transient CVar cvar_enabled;
    private transient CVar cvar_preset;
    private transient CVar cvar_saveTrigger;
    
    void SetCVarInt(PlayerInfo plr, string name, int value)
    {
        if (!plr) return;
        CVar cvar = CVar.GetCVar(name, plr);
        if (cvar) cvar.SetInt(value);
    }
    
    void SetCVarFloat(PlayerInfo plr, string name, double value)
    {
        if (!plr) return;
        CVar cvar = CVar.GetCVar(name, plr);
        if (cvar) cvar.SetFloat(value);
    }
    
    void SetCVarBool(PlayerInfo plr, string name, bool value)
    {
        if (!plr) return;
        CVar cvar = CVar.GetCVar(name, plr);
        if (cvar) cvar.SetBool(value);
    }
    
    void SaveCurrentAsCustom(PlayerInfo plr)
    {
        if (!plr) return;
        CVar samples = CVar.GetCVar("cynic_blur_samples", plr);
        CVar strength = CVar.GetCVar("cynic_blur_strength", plr);
        CVar velocity = CVar.GetCVar("cynic_blur_velocity_scale", plr);
        CVar chromatic = CVar.GetCVar("cynic_blur_chromatic", plr);
        
        if (samples) SetCVarInt(plr, "cynic_blur_custom_samples", samples.GetInt());
        if (strength) SetCVarFloat(plr, "cynic_blur_custom_strength", strength.GetFloat());
        if (velocity) SetCVarFloat(plr, "cynic_blur_custom_velocity_scale", velocity.GetFloat());
        if (chromatic) SetCVarBool(plr, "cynic_blur_custom_chromatic", chromatic.GetBool());
        
        SetCVarInt(plr, "cynic_blur_preset", 5);
        lastPreset = 5;
    }
    
    void ApplyPreset(PlayerInfo plr, int preset)
    {
        switch(preset)
        {
            case 0:
                SetCVarInt(plr, "cynic_blur_samples", 6);
                SetCVarFloat(plr, "cynic_blur_strength", 0.5);
                SetCVarFloat(plr, "cynic_blur_velocity_scale", 0.8);
                SetCVarBool(plr, "cynic_blur_chromatic", false);
                break;
            case 1:
                SetCVarInt(plr, "cynic_blur_samples", 10);
                SetCVarFloat(plr, "cynic_blur_strength", 0.7);
                SetCVarFloat(plr, "cynic_blur_velocity_scale", 1.2);
                SetCVarBool(plr, "cynic_blur_chromatic", true);
                break;
            case 2:
                SetCVarInt(plr, "cynic_blur_samples", 14);
                SetCVarFloat(plr, "cynic_blur_strength", 0.85);
                SetCVarFloat(plr, "cynic_blur_velocity_scale", 1.8);
                SetCVarBool(plr, "cynic_blur_chromatic", true);
                break;
            case 3:
                SetCVarInt(plr, "cynic_blur_samples", 16);
                SetCVarFloat(plr, "cynic_blur_strength", 1.0);
                SetCVarFloat(plr, "cynic_blur_velocity_scale", 3.5);
                SetCVarBool(plr, "cynic_blur_chromatic", true);
                break;
            case 4:
                SetCVarInt(plr, "cynic_blur_samples", 16);
                SetCVarFloat(plr, "cynic_blur_strength", 1.0);
                SetCVarFloat(plr, "cynic_blur_velocity_scale", 5.0);
                SetCVarBool(plr, "cynic_blur_chromatic", true);
                break;
            case 5:
                CVar customSamples = CVar.GetCVar("cynic_blur_custom_samples", plr);
                CVar customStrength = CVar.GetCVar("cynic_blur_custom_strength", plr);
                CVar customVelocity = CVar.GetCVar("cynic_blur_custom_velocity_scale", plr);
                CVar customChromatic = CVar.GetCVar("cynic_blur_custom_chromatic", plr);
                
                if (customSamples) SetCVarInt(plr, "cynic_blur_samples", customSamples.GetInt());
                if (customStrength) SetCVarFloat(plr, "cynic_blur_strength", customStrength.GetFloat());
                if (customVelocity) SetCVarFloat(plr, "cynic_blur_velocity_scale", customVelocity.GetFloat());
                if (customChromatic) SetCVarBool(plr, "cynic_blur_chromatic", customChromatic.GetBool());
                break;
        }
    }
    
    override void OnRegister()
    {
        initialized = false;
        presetInitialized = false;
        lastPreset = -1;
    }
    
    override void PlayerEntered(PlayerEvent e)
    {
        PlayerInfo plr = players[e.PlayerNumber];
        if (plr)
        {
            xtravel = 0;
            ytravel = 0;
            initialized = false;
            lastPreset = -1;
            presetInitialized = false;
        }
    }
    
    override void WorldTick()
    {
        PlayerInfo plr = players[consoleplayer];
        if (!plr)
            return;
        
        if (!cvar_enabled)
        {
            cvar_blurStrength = CVar.GetCVar("cynic_blur_strength", plr);
            cvar_samples = CVar.GetCVar("cynic_blur_samples", plr);
            cvar_velocityScale = CVar.GetCVar("cynic_blur_velocity_scale", plr);
            cvar_chromatic = CVar.GetCVar("cynic_blur_chromatic", plr);
            cvar_enabled = CVar.GetCVar("cynic_blur_enabled", plr);
            cvar_preset = CVar.GetCVar("cynic_blur_preset", plr);
            cvar_saveTrigger = CVar.GetCVar("cynic_blur_savecustom_trigger", plr);
            
            if (!cvar_enabled)
                return;
        }
        
        if (cvar_saveTrigger && cvar_saveTrigger.GetInt() != 0)
        {
            SaveCurrentAsCustom(plr);
            SetCVarInt(plr, "cynic_blur_savecustom_trigger", 0);
        }
        
        int currentPreset = cvar_preset ? cvar_preset.GetInt() : 1;
        if (!presetInitialized || currentPreset != lastPreset)
        {
            ApplyPreset(plr, currentPreset);
            lastPreset = currentPreset;
            presetInitialized = true;
        }
        
        if (plr.health > 0 && cvar_enabled && cvar_enabled.GetBool())
        {
            let mo = plr.mo;
            if (mo)
            {
                yaw = mo.GetPlayerInput(ModInput_Yaw);
                pitch = -mo.GetPlayerInput(ModInput_Pitch);
                
                if (!initialized)
                {
                    prevPos = mo.pos;
                    initialized = true;
                }
                else
                {
                    Vector3 deltaPos = mo.pos - prevPos;
                    double moveSpeed = sqrt(deltaPos.x * deltaPos.x + deltaPos.y * deltaPos.y);
                    
                    if (moveSpeed > 0.001)
                    {
                        double moveAngle = atan2(deltaPos.y, deltaPos.x) * 180.0 / 3.14159265359;
                        double relAngle = (moveAngle - mo.angle) * 3.14159265359 / 180.0;
                        double forwardMove = cos(relAngle) * moveSpeed;
                        double sideMove = sin(relAngle) * moveSpeed;
                        
                        double blurStrength = cvar_blurStrength ? cvar_blurStrength.GetFloat() : 0.5;
                        double velocityScale = cvar_velocityScale ? cvar_velocityScale.GetFloat() : 1.0;
                        double amount_walk = blurStrength * 10.0 * velocityScale;
                        
                        xtravel += sideMove * amount_walk * 0.625;
                        ytravel += forwardMove * amount_walk;
                    }
                    
                    prevPos = mo.pos;
                }
            }
        }
    }
    
    override void NetworkProcess(ConsoleEvent e)
    {
        PlayerInfo plr = players[e.Player];
        if (!plr || e.Name != "liveupdate")
            return;
        
        if (!cvar_enabled || !cvar_enabled.GetBool())
            return;
        
        let mo = plr.mo;
        if (!mo)
            return;
        
        if (!initialized)
            return;
        
        double velocityScale = cvar_velocityScale ? cvar_velocityScale.GetFloat() : 1.0;
        double blurStrength = cvar_blurStrength ? cvar_blurStrength.GetFloat() : 0.5;
        
        double amount = blurStrength * 0.003 * velocityScale;
        double amount_walk = blurStrength * 1.0 * velocityScale;
        double amount_jump = blurStrength * 1.0 * velocityScale;
        
        xtravel = xtravel * 0.85 + yaw * amount * 0.625;
        ytravel = ytravel * 0.85 + pitch * amount;
        
        double forwardMove = plr.cmd.forwardmove;
        double sideMove = plr.cmd.sidemove;
        
        if (abs(forwardMove) > 0 || abs(sideMove) > 0)
        {
            xtravel += sideMove * amount_walk * 0.01 * 0.625;
            ytravel += forwardMove * amount_walk * 0.01;
        }
        
        double velLength = mo.vel.x * mo.vel.x + mo.vel.y * mo.vel.y;
        if (velLength > 0)
        {
            double invLength = 1.0 / sqrt(velLength);
            double dirX = mo.vel.x * invLength;
            double dirY = mo.vel.y * invLength;
            double angle = atan2(dirY, dirX) - (mo.angle + 180) % 360;
            
            double sidevel = sin(angle) * sqrt(velLength);
            double walkvel = cos(angle) * sqrt(velLength);
            if (mo.pitch > 0) walkvel = -walkvel;
            
            xtravel += sidevel * amount_walk * 0.625;
            ytravel += mo.vel.z * amount_jump + walkvel * amount_walk;
        }
        
        if (xtravel > 1000.0) xtravel = 1000.0;
        if (xtravel < -1000.0) xtravel = -1000.0;
        if (ytravel > 1000.0) ytravel = 1000.0;
        if (ytravel < -1000.0) ytravel = -1000.0;
    }
    
    override void UiTick()
    {
        PlayerInfo plr = players[consoleplayer];
        if (!plr)
            return;
        
        if (!cvar_enabled)
            return;
        
        if (plr.health > 0)
        {
            bool mblurEnabled = cvar_enabled.GetBool();
            if (mblurEnabled)
            {
                EventHandler.SendNetworkEvent("liveupdate");
                
                double xclamp = xtravel;
                double yclamp = ytravel;
                if (xclamp > 1000.0) xclamp = 1000.0;
                if (xclamp < -1000.0) xclamp = -1000.0;
                if (yclamp > 1000.0) yclamp = 1000.0;
                if (yclamp < -1000.0) yclamp = -1000.0;
                
                int screenWidth = screen.getwidth();
                int screenHeight = screen.getheight();
                if (screenWidth > 0 && screenHeight > 0)
                {
                    vector2 viewVelocity = (
                        (xclamp / screenWidth),
                        (yclamp / screenHeight)
                    );
                    
                    Shader.SetUniform2f(plr, "directionalblur", "ViewVelocity", viewVelocity);
                    
                    if (cvar_blurStrength)
                        Shader.SetUniform1f(plr, "directionalblur", "u_blurStrength",
                            cvar_blurStrength.GetFloat());
                    
                    if (cvar_samples)
                        Shader.SetUniform1i(plr, "directionalblur", "u_samples",
                            cvar_samples.GetInt());
                    
                    if (cvar_velocityScale)
                        Shader.SetUniform1f(plr, "directionalblur", "u_velocityScale",
                            cvar_velocityScale.GetFloat());
                    
                    if (cvar_chromatic)
                        Shader.SetUniform1i(plr, "directionalblur", "u_chromaticAberration",
                            cvar_chromatic.GetBool() ? 1 : 0);
                    
                    Shader.SetEnabled(plr, "directionalblur", true);
                }
            }
            else
            {
                Shader.SetEnabled(plr, "directionalblur", false);
            }
        }
    }
    
}
