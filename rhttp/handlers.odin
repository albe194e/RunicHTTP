package rhttp;

import "core:fmt"


@(private)
handle_request :: proc(r : Router, req : Request) -> (bytes : []byte) {

    for route in r.routes {
        if route.path == req.path {
            return parse_response(route.action())
        }
    }

    fmt.printfln("Did not find any routes matching: %v", req.path)
    return bytes;
}
