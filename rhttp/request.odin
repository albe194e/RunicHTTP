package rhttp;

import "core:fmt"

Request :: struct {
    rl : Request_line,
    body : string, // == ""
    headers : Headers,
}
Request_line :: struct {
    method : Request_method,
    path : string,
    version : string
}

Request_method :: enum {
    NONE,
    GET
}

init_request :: proc(r : ^Request) {
    r.headers.kv = make(map[string]string);
}

destroy_request ::proc(r : ^Request) {
    delete(r.headers.kv);
}

@(private)
handle_request :: proc(router : Router, req : Request) -> (resp : Response, err : RhttpError) {

    route, found := map_route_path(router, req);

    if !found {
        err.status = .Not_Found;
        err.message = fmt.aprintf("Could not find any routes matching: %v", req.rl.path);
    }

    //Check if any errors happened before callback function. NONE means no errors have been set
    if err.status == .NONE {
        resp, err = route.action();
    }

    return resp, err;
}
