% core/world_of_darkwood/combat/lore_asset_expansion.m
% Production-grade AI pathfinding and pack-logic corrections.
% Focus: deterministic stall handling, micro-link “panic detours”, and pack coordination.

%% RNG & DETERMINISM

rng(1337,'twister');             % fixed seed for reproducible simulations [web:1]

%% PARAMETER DEFINITIONS

dt      = 0.1;                   % seconds per tick [web:1]
T_max   = 300;                   % max simulated time [web:1]
N_ticks = round(T_max/dt);       % total ticks [web:1]

N_nodes = 200;                   % navgraph size [web:1]
W       = inf(N_nodes);          % macro graph adjacency [web:8]
for i = 1:N_nodes
    W(i,i) = 0;
end

edge_prob = 0.03;                % macro edge density [web:8]
for i = 1:N_nodes
    for j = i+1:N_nodes
        if rand < edge_prob
            d = 1 + 4*rand;      % base travel cost [web:3]
            W(i,j) = d;
            W(j,i) = d;
        end
    end
end

% Micro-links ~ off-mesh links / corner hops [web:8]
W_micro          = zeros(N_nodes);
micro_link_prob  = 0.15;
for i = 1:N_nodes
    for j = 1:N_nodes
        if i ~= j && W(i,j) == inf && rand < micro_link_prob
            W_micro(i,j) = 6 + 4*rand;   % higher than main edges; used only in panic [web:3]
        end
    end
end

% Stall detection and panic tuning [web:3]
stall_window_ticks   = 15;
min_progress_cost    = 0.5;
panic_radius_factor  = 1.5;
obstacle_shove_factor= 0.6;
aggression_spike     = 1.3;

% Agent parameters [web:4]
N_agents   = 8;
v_base     = 1.2;
forest_mood= 0.4;                % [-1,1] [web:4]
night_phase= 1;                  % 0=day,1=night [web:4]

%% STATE VARIABLES

pos          = randi(N_nodes, N_agents, 1);  % current node indices
spawn_pos    = pos;                          % initial positions (for metrics)
target_node  = randi(N_nodes);              % main objective
aggression   = ones(N_agents,1);
panic_mode   = false(N_agents,1);
stall_counter= zeros(N_agents,1);

% 1=breacher, 2=flanker, 3=howler, 4=harrier [web:4]
roles = zeros(N_agents,1);
for k = 1:N_agents
    r = rand;
    if r < 0.25
        roles(k) = 1;
    elseif r < 0.5
        roles(k) = 2;
    elseif r < 0.75
        roles(k) = 3;
    else
        roles(k) = 4;
    end
end

% Per-agent per-tick panic log (for robust metrics)
panic_log = false(N_agents, N_ticks);

%% PACK CONTROLLER

if night_phase == 1
    mood_bias = 1 + 0.5*forest_mood;        % stronger focus at night [web:4]
else
    mood_bias = 1;
end

center_node = mode(pos);                    % pack center [web:4]
d_center_target = path_distance(W, center_node, target_node);

focus_weight = 1/(1 + exp(-0.1*(d_center_target - 10))) * mood_bias;  % [web:4]

% Alternate flank target proposal (howlers/scouts)
alt_target_node = target_node;
if rand < 0.2
    alt_target_node = randi(N_nodes);
end

effective_target = zeros(N_agents,1);
for k = 1:N_agents
    switch roles(k)
        case 1          % breacher
            effective_target(k) = target_node;
        case 2          % flanker
            effective_target(k) = alt_target_node;
        case 3          % howler/scout
            if rand < 0.5
                effective_target(k) = alt_target_node;
            else
                effective_target(k) = target_node;
            end
        case 4          % harrier
            effective_target(k) = target_node;
    end
end

%% MAIN SIMULATION LOOP

last_pos = pos;                     % last macro node for stall detection

for t = 1:N_ticks

    for k = 1:N_agents
        current = pos(k);
        target  = effective_target(k);

        % 1) Shortest path on macro (+micro if panic)
        use_micro = panic_mode(k);
        [dist, prev] = dijkstra(W, W_micro, current, use_micro);
        if isinf(dist(target))
            stall_counter(k) = stall_counter(k) + 1;
            panic_log(k,t)  = panic_mode(k);
            continue;
        end

        path = reconstruct_path(prev, current, target);
        if numel(path) < 2
            stall_counter(k) = stall_counter(k) + 1;
            panic_log(k,t)  = panic_mode(k);
            continue;
        end

        % 2) Step along discrete graph path
        next_node = path(2);
        pos(k)    = next_node;

        % 3) Stall detection via path-distance delta [web:3]
        d_prog = path_distance(W, last_pos(k), pos(k));
        if d_prog < min_progress_cost
            stall_counter(k) = stall_counter(k) + 1;
        else
            stall_counter(k) = 0;
            last_pos(k)      = pos(k);
        end

        % 4) Panic detour activation
        if stall_counter(k) >= stall_window_ticks
            panic_mode(k) = true;
            aggression(k) = aggression(k) * aggression_spike;

            % Local cost rescaling (“obstacle shove”) [web:3]
            neighbors = find(W(current,:) < inf);
            for nb = neighbors
                W(current,nb) = W(current,nb) * obstacle_shove_factor;
                W(nb,current) = W(nb,current) * obstacle_shove_factor;
            end

            % Radius expansion: compress far costs relative to target [web:3]
            for j = 1:N_nodes
                if dist(j) < inf && dist(j) > panic_radius_factor*dist(target)
                    new_cost = dist(target) * panic_radius_factor;
                    if isinf(W(current,j))
                        W(current,j) = new_cost;
                        W(j,current) = new_cost;
                    else
                        W(current,j) = min(W(current,j), new_cost);
                        W(j,current) = W(current,j);
                    end
                end
            end

            stall_counter(k) = 0;
        end

        % 5) Door/barricade destruction: unlock one high-cost edge [web:3]
        if panic_mode(k)
            candidates = find(W(current,:) > 5 & W(current,:) < inf);
            if ~isempty(candidates)
                j = candidates(randi(numel(candidates)));
                W(current,j) = 1.0;
                W(j,current) = 1.0;
            end
        end

        panic_log(k,t) = panic_mode(k);
    end

    % Early-out: pack objective satisfied [web:4]
    if all(pos(roles==1) == target_node) && all(pos(roles==4) == target_node)
        N_ticks = t;              % truncate metric window
        panic_log = panic_log(:,1:t);
        break;
    end
end

%% OUTPUT METRICS

% Mean breacher engagement time from spawn → target [web:4]
breacher_idx   = find(roles == 1);
breacher_times = zeros(numel(breacher_idx),1);
for i = 1:numel(breacher_idx)
    start_node = spawn_pos(breacher_idx(i));
    d_path     = path_distance(W, start_node, target_node);
    breacher_times(i) = d_path / v_base;
end
mean_breacher_engage_time = mean(breacher_times);      % seconds

% Fraction of simulation ticks spent in panic per agent [web:3]
panic_fraction_per_agent = sum(panic_log,2) ./ N_ticks;
panic_fraction_estimate  = mean(panic_fraction_per_agent);

% Role distribution entropy (pack coordination richness) [web:4]
role_counts = accumarray(roles,1,[4,1]);
p_roles     = role_counts / sum(role_counts);
p_roles(p_roles==0) = 1;
coordination_entropy = -sum(p_roles .* log2(p_roles));

% Struct for engine-side consumption (no printing in shipped build)
ai_debug_metrics = struct( ...
    'mean_breacher_engage_time', mean_breacher_engage_time, ...
    'panic_fraction_estimate',   panic_fraction_estimate, ...
    'coordination_entropy',      coordination_entropy, ...
    'panic_fraction_per_agent',  panic_fraction_per_agent, ...
    'roles',                     roles, ...
    'forest_mood',               forest_mood, ...
    'night_phase',               night_phase);

%% PURE FUNCTIONS (BOTTOM OF FILE FOR MATLAB)

function [dist, prev] = dijkstra(W_main, W_micro, s, use_micro)
    % Deterministic Dijkstra with optional micro-links. [web:8]
    N     = size(W_main,1);
    W_eff = W_main;
    if use_micro
        idx_micro      = W_micro > 0;
        merged_cost    = W_micro(idx_micro);
        existing_cost  = W_eff(idx_micro);
        W_eff(idx_micro) = min(existing_cost, merged_cost);
    end

    dist    = inf(N,1);
    prev    = zeros(N,1);
    visited = false(N,1);
    dist(s) = 0;

    for i = 1:N
        % choose minimal unvisited node
        mask = ~visited;
        if ~any(mask)
            break;
        end
        masked_dist = dist;
        masked_dist(~mask) = inf;
        [~,u] = min(masked_dist);
        if isinf(dist(u))
            break;
        end
        visited(u) = true;

        neighbors = find(W_eff(u,:) < inf);
        for v = neighbors
            if visited(v)
                continue;
            end
            alt = dist(u) + W_eff(u,v);
            if alt < dist(v)
                dist(v) = alt;
                prev(v) = u;
            end
        end
    end
end

function path = reconstruct_path(prev, s, t)
    % Reconstruct shortest path from s to t. [web:8]
    if s == t
        path = s;
        return;
    end
    if prev(t) == 0
        path = [];
        return;
    end
    path = t;
    cur  = t;
    while cur ~= s
        cur = prev(cur);
        if cur == 0
            path = [];
            return;
        end
        path = [cur; path]; %#ok<AGROW>
    end
end

function d = path_distance(W_main, i, j)
    % Shortest-path distance used as abstract movement metric. [web:10]
    if i == j
        d = 0;
        return;
    end
    [dist, ~] = dijkstra(W_main, zeros(size(W_main)), i, false);
    d = dist(j);
end
