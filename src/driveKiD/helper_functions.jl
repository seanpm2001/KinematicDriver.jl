"""
    Prescribed momentum flux as a function of time
"""
@inline function ρw_helper(t, w1, t1)
    return t < t1 ? w1 : 0.0
    # return t < t1 ? w1 * sin(pi * t / t1) : 0.0
end

"""
    Returns the number of new activated aerosol particles and updates aerosol number density
"""
@inline function aerosol_activation_helper(params, q_tot, q_liq, N_aer, N_aer_0, T, p, ρ, ρw, dt, act_mask)

    microphys_params = KP.microphysics_params(params)
    thermo_params = CM.Parameters.thermodynamics_params(microphys_params)

    FT = eltype(q_tot)
    S_Nl::FT = FT(0)
    S_Na::FT = FT(0)

    q = TD.PhasePartition(q_tot, q_liq, FT(0))
    S::FT = TD.supersaturation(thermo_params, q, ρ, T, TD.Liquid())

    r_dry = KP.r_dry(params)
    std_dry = KP.std_dry(params)
    κ = KP.κ(params)
    w = ρw / ρ

    if (S < FT(0) || w <= FT(0) || N_aer <= FT(0) || act_mask == FT(0))
        return (; S_Nl, S_Na)
    end

    # scheme = CMT.ARG2000Type()
    scheme = CMAA.MLEmulatedAerosolActivation(joinpath(pkgdir(CM), "aerosol_activation_emulators", "1modal_nn_machine_naive.jls"))

    aerosol_distribution = CMAM.AerosolDistribution((CMAM.Mode_κ(r_dry, std_dry, N_aer_0, FT(1), FT(1), FT(0), κ, 1),))
    N_act = CMAA.N_activated_per_mode(microphys_params, scheme, aerosol_distribution, T, p, w, q)[1]

    if isnan(N_act)
        return (; S_Nl, S_Na)
    end

    S_Nl = max(0, N_act - (N_aer_0 - N_aer)) / dt
    # S_Nl = min(N_act, N_aer) / dt
    S_Na = -S_Nl

    return (; S_Nl, S_Na)
end
