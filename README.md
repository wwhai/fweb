
# :joystick: FWEB:FunnyWeb

Fweb is a lightweight web framwork implements with erlang. Build top on cowboy.

## :blue_car: QuickStart

### 1. Server

1. start fweb

   ```erlang
   % name :erlang module
   % mapping : URL
   fweb:add_mapping([#{name =>index,mapping =>"/index"}]).
   ```

   

2. stop fweb

   ```erlang
   fweb.stop()
   ```

### 2. Handler And Mapping
Handler looks like similar other language or framework,such as springframework or php called controller. Mapping in other framework called request mapping or router. Just no more. I believe you have learned some web framework knowledge before.

Handler in fweb is a normal erlang module which  mappinged by "mapping" property, mapping is a context url path as the top layer.

When we sending a http request, we should in the url format:

```shell
http://host:port/mapping@action?k=v&m=n………
```

Example: A blog, allow user to  create ,upgrade, remove, search theirs article. First add a module named blog:

```erlang
-module(article_handler)
-exlort(_Method, [add/1, upgrade/1, remote/1, search/1])
add(_Method, [Title, Content, Author], Body) ->
  {rest,<<"OK">>}.
upgrade(_Method, [Title, Content, Author], Body) ->
  {rest,<<"OK">>}.
remove(_Method, [{id,1}]) ->
  {rest,<<"OK">>}.
search(_Method, [Title, Content, Author]) ->
  {rest,<<"OK">>}.
```

Action is a 2 or 3 arity function, first is http method, second  argument is a list which contains all request params, third is body if Method is post or put. As your see the action function return a 2 elements tuple, It's `{type, Result}`,  first of element of `return_type`, this is an atom which one of those:

1. rest: A rest result
2. text: A text result
3. file: File
4. stream: binary stream

Second element is return result. It have a special rule in those function what must return binary or list!
Those are llegal return:

```erlang
{rest, <<"OK">>}
{rest, "OK"}
{text, <<"OK">>}
{text, "OK"}
```

Next we add our handler to fweb.Just use `add_handler/1`function.

```erlang
Handlers = [#{name => article_handler, mapping => "/article"}],
fweb:add_mapping(Handlers).
fweb:add_handler(#{name => article_handler, mapping => "/article"}).
```
### 3. Interceptor

Interceptor in java world maybe well known, In python world it called "MiddleWare". In fweb the Interceptor have some meaning: handle some request in special url  before http request invoke handler.

Interceptor is also a normal erlang module, but have a little special:must implements a behaviour which have 1 callback:

```erlang
handle(Path,[Args]) -> accept|deny.
```
The callback `init/0` for initial some data, mostly it is a state for handler; `handle/2` is most important, request whill arrived here, and the return result decide if continue. First argument is url path, second argument is a request params list. Last is `finished/0`callback, It seems no use bug as usual we print some log. 

Next we try a demo to learn interceptor, Example code:

```erlang
List = [#{name => i1, mapping => "/a"},
        #{name => i2, mapping => "/b"}],
fweb:add_interceptors(List)
fweb:add_interceptor(#{name => article_handler, path => "/article"})
```

We add an interceptor for "/user" mapping, it will intercept every request which mapping is "/user". We can use interceptor to ensure security requesrt.

### 4. Fweb Cache

Fweb Cache is a simple cache database seems like redis. Yes ,you can use Fweb Cache like you how to use redis. Of course, It's a lightweight database, no enough than redis, only for daily web stage.

```erlang
%% type=k::term(),v::term()
fweb_cache:put(k, v),
fweb_cache:put(k, v, timeout),
fweb_cache:get(k, v),
fweb_cache:remove(k),
fweb_cache:remove(Klist),
fweb_cache:flush(),
```

## Cloud function

```
f().
E = [[{1,[{<<"k">>,<<"v">>}]},{2,2},{3,3},{4,4},{5,5}],<<"ok">>].
{R, S} = luerl_sandbox:run(<<"function callback(request, cloud)
                                          print('request:', request[1]['k'],request[2],request[3],request[4])
                                          print('cloud:', cloud)
                                          return request, cloud
                              end">>,
                          luerl_sandbox:init(),
                          999999,
                          [{priority, low}],
                          2000,
                          [[callback], [[#{k=>v},2,3,4,5], ok]]).
                          R.

```