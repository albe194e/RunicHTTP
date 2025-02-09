package rhttp;

import "core:fmt"

Request_line :: struct {
    method : Request_method,
    path : string,
    version : string
}

Headers :: struct {
    kv : map[string]string
}

Request_method :: enum {
    NONE,
    GET
}

Request :: struct {
    rl : Request_line,
    headers : Headers,
    body : Maybe(string), // == ""
}

init_request :: proc(r : ^Request) {
    r.headers.kv = make(map[string]string)
}

destroy_request ::proc(r : ^Request) {
    delete(r.headers.kv)
}


@(private)
handle_request :: proc(router : Router, req : Request) -> (resp : Response, err : RhttpError) {

    reqTest := Request{
        rl = {
            method = .GET,
            path = "/index",
            version = "HTTP/1.1"
        }
    }
    route, found := map_route_path(router, req);

    if !found {
        //TODO: Add not found status code
        return;
    }

    resp, err = route.action()
    fmt.printfln("Response: %#v", resp)

    return resp, err;
}
