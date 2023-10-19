## FlEx

FlEx it's a micro-framework for backend inspired by the simplicity of Flask and the complication to use Phoenix in very
small applications

One of the cores of this micro-framework it's be flexible, you can define your whole app in a single file or split in a 
lot of more files, basic rules, nothing to be followed

This project doesn't pretend to replace Phoenix, the opposite we LOVE Phoenix and we're taking a lot of inspiration on 
the use and implementation of Phoenix, but sometimes a lot of stuff it's too overkill for some very small servers and 
more when you want to create a very small service

The design it's based on [Plug](https://hexdocs.pm/plug/https.html) so it's FULLY COMPATIBLE WITH ALL THE PLUGS! and you
can create your own plugs in the same format and the same way to use, 100% compatibility

Also includes some useful plugs to create/configure your server quickly

## Concepts

#### Server

All the concepts are just described, the examples are in the guides and the module docs

The main piece it's the `server`, that contains the routes and the functions and this can be created using the module 
`FlEx.Server` and this contains all the core to handle routes

#### Routers
Also it's not recommended have all in a single file so to divide the problem usin the routers, that can be created using
the module `FlEx.Router` and this can handle in the same way the routes, actually, `FlEx.Server` it's a router itself

#### Router Scopes

In the router you can define scopes of route, this will add the scoped route to the defined inner route as a prefix of 
the route, so if you have `/some/route` with the scope `/api/v1` the final route will be `/api/v1/some/route` and all 
the defined routes in the scope will have the same route prefix

#### Router pipelines

The router can define plugs, and this will be added to the execution of every route, also you can define exclusive plugs
in the scope and another exclusive plugs in every router

#### Controller handling

Defining a route include the route and the function to call when the route it's called, and this function can be defined
in the same router, or an external module, the concept says that must be named "controller" and it is, but this library
doesn't need implement a specific module for controllers, so you can just create your function in your module and just
receive 2 parameters in the function (the connection and the parameters)

## Installation

If [available in Hex](https://hex.pm/packages/fl_ex), the package can be installed
by adding `fl_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fl_ex, "~> 0.1.1"}
  ]
end
```

## Index

- [Basic Usage](./guides/basic_usage.md)
- [Routing](./guides/routing.md)
- [Configuration](./guides/configuration.md)
- [Testing](./guides/testing.md)

## The example

This project includes a complete implementation example (server, routers, testing), just check the folder 
[fl_ex_example](./fl_ex_example)

## Roadmap

- [x] Server
- [x] Separated routers
- [ ] Https
- [ ] Live code changes
- [ ] Render
    - [x] JSON
    - [ ] HTML
- [x] Compatible with Plugs (100%)
- [x] Plugs for whole router
- [x] Plugs exclusive for `scope`
- [ ] `pipeline` to create plug flows and refeer to `scope` or route
- [x] Private plugs for specific routes
- [ ] Testing
    - [x] Basic json testing
    - [ ] More helpers
