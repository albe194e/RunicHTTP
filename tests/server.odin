package tests;

import "core:testing"

import "../rhttp"

@(test)
server_test :: proc(t: ^testing.T) {

    s : rhttp.Server;

    rhttp.init_server(&s);
    defer rhttp.destroy_server(&s);

    rhttp.add_route(
        &s.router,
        rhttp.Route{
            path = "/index",
            action = my_get_action
        }
    )

    rhttp.start_server(&s)

}

my_get_action :: proc() -> (r : rhttp.Response, err : rhttp.RhttpError) {

    body := "HTTP/1.1 200 OK\r\nServer: RunicHTTP Server\r\nContent-Type: text/html\r\n\r\n<html><body><h1>Test!!!</h1><body></html>"
    r.body = body

    return r, err;
}