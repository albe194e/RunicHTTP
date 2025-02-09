package main

import "core:fmt"
import "core:net"
import "core:strings"

import "rhttp"

main :: proc() {
    
    s : rhttp.Server;
    sc := rhttp.load_config_from_file("server_config.json", .SERVER).(rhttp.Server_config);

    rhttp.init_server(&s, sc);
    defer rhttp.destroy_server(&s)

    rhttp.add_route(
        &s.router,
        rhttp.Route{
            path = "/index",
            action = my_get_action
        }
    )

    rhttp.add_route(
        &s.router,
        rhttp.Route{
            path = "/login",
            action = my_login_action
        }
    )

    rhttp.start_server(&s)
}

my_get_action :: proc() -> (r : rhttp.Response, err: rhttp.RhttpError) {

    rhttp.init_response(&r)
    body := "<body>Hello, world!</body>"
    r.body.content = body
    r.status_line.status_code = .Not_Found

    r.headers["Accept"] = "application/json"
    

    return r, err;
}

my_login_action :: proc() -> (r : rhttp.Response, err: rhttp.RhttpError) {

    body := ""
    r.body.content = body
    r.status_line.status_code = .OK
    return r, err;
}
