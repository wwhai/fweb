%% @author: 
%% @description: 
-module(fweb_SUITE).
-compile([export_all, nowarn_export_all]).
-include_lib("eunit/include/eunit.hrl").
-include_lib("common_test/include/ct.hrl").

%%--------------------------------------------------------------------
%% Setups
%%--------------------------------------------------------------------
all() ->
    [{group, test}].
groups() ->
    [{test, [sequence], [test_lua]}].
init_per_suite(_Cfg) ->
    application:ensure_all_started(fweb),
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

test_lua(_) ->
    E = [[{1,[{<<"k">>,<<"v">>}]},{2,2},{3,3},{4,4},{5,5}],<<"ok">>, 0],
    Script = <<"function callback(request, cloud)
                                        print('request:', request[1]['k'],
                                                          request[2],
                                                          request[3],
                                                          request[4])
                                        print('cloud:', cloud)
                                        print('test_fun:', test_fun(0))
                                        print('test_fun:', test_fun(1))
                                        return request, cloud, test_fun(0)
                   end"
                >>,
    Reduction = 999999,
    Period = [{priority, low}],
    Timeout = 2000,
    CallBackFunction = callback,
    CallBackArgs = [[#{k => v},2,3,4,5], ok],
    R = gen_server:call(fweb_cloud_function, {run_script,
                                        Script,
                                        Reduction,
                                        Period,
                                        Timeout,
                                        CallBackFunction,
                                        CallBackArgs}),
    E = R.