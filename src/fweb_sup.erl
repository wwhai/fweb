%%%-------------------------------------------------------------------
%% @doc fweb top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(fweb_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 0,
                 period => 1},
    Fweb = #{id => 'fweb',
             start => {'fweb', start_link, [{port, 9990}]},
             restart => permanent,
             shutdown => 2000,
             type => worker,
             modules => ['fweb']},
    FwebCloudFunction = #{id => 'fweb_cloud_function',
                          start => {'fweb_cloud_function', start_link, [ok]},
                          restart => permanent,
                          shutdown => 2000,
                          type => worker,
                          modules => ['fweb_cloud_function']},
    MappingManager = #{id => 'mapping_manager',
                       start => {'fweb_mapping_manager', start_link, [ok]},
                       restart => permanent,
                       shutdown => 2000,
                       type => worker,
                       modules => ['fweb_mapping_manager']},
    CacheManager = #{id => 'cache_manager',
                     start => {'fweb_cache_manager', start_link, [ok]},
                     restart => permanent,
                     shutdown => 2000,
                     type => worker,
                     modules => ['fweb_cache_manager']},
    InterceptorManager = #{id => 'interceptor_manager',
                           start => {'fweb_interceptor_manager', start_link, [ok]},
                           restart => permanent,
                           shutdown => 2000,
                           type => worker,
                           modules => ['fweb_interceptor_manager']},
    ChildSpecs = [Fweb,
                  FwebCloudFunction,
                  MappingManager,
                  CacheManager,
                  InterceptorManager],
    {ok, {SupFlags, ChildSpecs}}.
