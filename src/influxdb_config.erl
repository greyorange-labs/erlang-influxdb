-module(influxdb_config).

-export([new/1]).

-export_type([config/0]).

-type config() ::
    #{
        scheme => string() | undefined,
        host := string(),
        port := inet:port_number(),
        sub_path => string() | undefined,
        username := string(),
        password := string(),
        database => string()
    }.

-spec new(Opts) -> config() when
    Opts ::
        #{
            scheme => iodata() | undefined,
            host => iodata(),
            port => inet:port_number(),
            sub_path => iodata() | undefined,
            username => iodata(),
            password => iodata(),
            database => iodata()
        }.
new(Opts) ->
    maps:map(
        fun
            (host, Host) ->
                unicode:characters_to_list(Host);
            (port, Port) when is_integer(Port), Port > 0, Port < 65536 ->
                Port;
            (username, Username) ->
                unicode:characters_to_list(Username);
            (password, Password) ->
                unicode:characters_to_list(Password);
            (database, Database) ->
                unicode:characters_to_list(Database);
            (scheme, Scheme) when is_list(Scheme) ->
                unicode:characters_to_list(Scheme);
            (scheme, undefined) ->
                "http";
            (sub_path, SubPath) when is_list(SubPath) ->
                unicode:characters_to_list(SubPath);
            (sub_path, undefined) ->
                ""
        end,
        maps:merge(
            #{
                scheme => "http",
                host => "localhost",
                port => 8086,
                sub_path => "",
                username => "root",
                password => "root"
            },
            Opts
        )
    ).
