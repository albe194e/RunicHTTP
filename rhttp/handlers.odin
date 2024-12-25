package rhttp;

import "core:fmt"

@(private)
handle_request :: proc(r : Router, req : Request) -> (bytes : []byte) {

    for route in r.routes {
        if route.path == req.path {
            bytes = route.action()
            break;
        }
    }

    return bytes;

}