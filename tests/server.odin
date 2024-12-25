package tests;

import "core:testing"

import "../rhttp"

@(test)
server_test :: proc(t: ^testing.T) {

    s : rhttp.Server;

    rhttp.init_server(&s);
    defer rhttp.destroy_server(&s);

    rhttp.start_server(&s)

}