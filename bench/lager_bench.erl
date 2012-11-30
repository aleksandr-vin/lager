-module(lager_bench).

-export([start/0]).

start() ->
    io:format("% Starting benchmarks...~n"),
    Result = filelib:fold_files(".", "^bench_.*\.erl$", false,
                                fun perform/2, []),
    io:format("% Result is: ~p~n", [Result]),
    ok.

perform(Filename, Acc) ->
    [{Filename, perform(Filename)}|Acc].

perform([]) ->
    [];
perform(Filename) when is_list(Filename) ->
    io:format("%%% Compiling ~p~n", [Filename]),
    Mod = filename:basename(Filename, ".erl"),
    perform(compile:file(Mod));
perform({ok, Mod}) ->
    io:format("%%% Loading ~p~n", [Mod]),
    perform(code:load_file(Mod));
perform({module, Mod}) ->
    io:format("%% Initializing ~p~n", [Mod]),
    State = Mod:init(),
    io:format("% Running ~p:test/0~n", [Mod]),
    {Time, _} = Result = timer:tc(Mod, test, []),
    io:format("% Elapsed time: ~p s~n", [Time / 1000000]),
    io:format("%% Terminating ~p~n", [Mod]),
    ok = Mod:terminate(State),
    Result;
perform(Other) ->
    io:format("% ~p", [Other]),
    Other.
