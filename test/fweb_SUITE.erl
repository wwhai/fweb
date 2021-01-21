%% @author: 
%% @description: 
-module(fweb_SUITE).
-compile([export_all, nowarn_export_all]).
-include_lib("eunit/include/eunit.hrl").
-export([test/2]).
-include_lib("common_test/include/ct.hrl").

%%--------------------------------------------------------------------
%% Setups
%%--------------------------------------------------------------------
all() ->
    [{group, test}].
groups() ->
    [{test, [sequence], [start_http]}].
init_per_suite(_Cfg) ->
    _Cfg.
end_per_suite(_) ->
    ok.
init_per_group(_Group , _Cfg) ->
    ok.
end_per_group(_Group, _Cfg) ->
    ok.
%%--------------------------------------------------------------------
%% Cases
%%--------------------------------------------------------------------
start_http(_) ->
    application:ensure_all_started(fweb).

test_lua() ->
    S0 = luerl:init(),
    S1 = luerl_lib_cloud:install(S0),
    {R, _} = luerl_sandbox:run(<<"return test(123)">>, S1, 20000, [{priority, high}], 2000, []).
