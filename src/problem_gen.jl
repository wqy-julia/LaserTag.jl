function cpp_emu_lasertag(r::Int; kwargs...)
    if r == 4
        obstacles = Set{Coord}(Coord(c) for c in ([5,7], [2,6], [4,3], [3,2], [4,2], [8,2], [10,2], [4,1]))
    else
        warn("r = $r not recognized.")
    end
    return gen_lasertag(7, 11; obstacles=obstacles, kwargs...)
end

function gen_lasertag(n_rows::Int,
                      n_cols::Int,
                      n_obstacles::Int,
                      reading_std::Float64=2.5;
                      discrete=false,
                      rng=Base.GLOBAL_RNG,
                      kwargs...)

    return gen_lasertag(n_rows, n_cols;
                        obstacles=gen_obstacles(n_rows, n_cols, n_obstacles, rng),
                        discrete=discrete,
                        reading_std=reading_std,
                        rng=rng,
                        kwargs...
                       )
end

function gen_obstacles(n_rows::Int, n_cols::Int, n_obstacles::Int, rng::AbstractRNG=Base.GLOBAL_RNG)
    f = Floor(n_rows, n_cols)
    obs_inds = randperm(rng, n_pos(f))[1:n_obstacles] # XXX inefficient
    obs_subs = ind2sub((n_cols, n_rows), obs_inds)
    obstacles = Set{Coord}(Coord(p) for p in zip(obs_subs...))
    for c in obstacles
        if !inside(f, c)
            @show c
            @show obs_inds
            @show obs_subs
            error("not inside")
        end
    end
    return obstacles
end

function gen_lasertag(n_rows::Int=7,
                      n_cols::Int=11;
                      rng=Base.GLOBAL_RNG,
                      obstacles=gen_obstacles(n_rows, n_cols, 8, rng),
                      discrete=false,
                      reading_std=2.5,
                      kwargs...)

    f = Floor(n_rows, n_cols)
    r = Coord(rand(rng, 1:f.n_cols), rand(rng, 1:f.n_rows))
    if discrete
        return LaserTagPOMDP{DMeas}(;floor=f,
                                     obstacles=obstacles,
                                     robot_init=r, 
                                     reading_std=reading_std,
                                     cdf=ReadingCDF(f, reading_std),
                                     kwargs...)
    else
        return LaserTagPOMDP{CMeas}(;floor=f,
                                     obstacles=obstacles,
                                     robot_init=r,
                                     reading_std=reading_std,
                                     kwargs...)
    end
end
