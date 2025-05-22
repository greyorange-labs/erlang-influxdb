%% @private
-module(influxdb_app).

-behaviour(application).

-export([start/2, stop/1]).

-spec start(start_type(), term()) ->
    {ok, pid()} | {ok, pid(), State :: term()} | {error, term()}.
-type start_type() :: normal | {takeover, node()} | {failover, node()}.

start(_StartType, _StartArgs) ->
    DefaultHttpcProfileConfigs = #{
        influxdb_query => [
            {max_sessions, 10},
            {max_keep_alive_length, 0},
            {max_pipeline_length, 0}
        ],
        influxdb_write => [
            {max_sessions, 10},
            {max_keep_alive_length, 0},
            {max_pipeline_length, 0}
        ]
    },

    HttpcProfileConfigMap = application:get_env(
        influxdb, httpc_profile_configs, DefaultHttpcProfileConfigs
    ),
    HttpcQueryProfileConfig = maps:get(influxdb_query, HttpcProfileConfigMap, []),
    HttpWriteProfileConfig = maps:get(influxdb_write, HttpcProfileConfigMap, []),
    {ok, _} =
        inets:start(
            httpc,
            [
                {profile, influxdb_query}
            ] ++ HttpcQueryProfileConfig
        ),
    {ok, _} =
        inets:start(
            httpc,
            [
                {profile, influxdb_write}
            ] ++ HttpWriteProfileConfig
        ),
    DefaultHackneyProfileConfigs = #{
        influxdb_query => [
            {max_connections, 10},
            {timeout, 15000}
        ],
        influxdb_write => [
            {max_connections, 10},
            {timeout, 15000}
        ]
    },
    HackneyProfileConfigMap = application:get_env(
        influxdb, hackney_profile_configs, DefaultHackneyProfileConfigs
    ),
    HackneyQueryProfileConfig = maps:get(influxdb_query, HackneyProfileConfigMap, []),
    HackneyWriteProfileConfig = maps:get(influxdb_write, HackneyProfileConfigMap, []),
    ok = hackney_pool:start_pool(influxdb_query, HackneyQueryProfileConfig),
    ok = hackney_pool:start_pool(influxdb_write, HackneyWriteProfileConfig),
    influxdb_sup:start_link().

-spec stop(State :: term()) -> term().
stop(_State) ->
    inets:stop(httpc, influxdb_query),
    inets:stop(httpc, influxdb_write),
    hackney_pool:stop_pool(influxdb_query),
    hackney_pool:stop_pool(influxdb_write),
    ok.
