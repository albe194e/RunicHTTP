package rhttp;

action :: #type proc() -> (Response, RhttpError);

Route :: struct {

    path : string,
    action : action,

}

Router :: struct {

    routes : [dynamic]Route
}

add_route :: proc(r : ^Router, route : Route) {
    append(&r.routes, route)
}

@(private)
map_route_path :: proc(router : Router, req : Request) -> (route : Route, ok : bool){

    for r in router.routes {
        if r.path == req.rl.path {
            route = r;
            ok = true;
            break;
        }
    }
    return route, ok
}

@(private)
init_router :: proc(r : ^Router) {

    r.routes = make([dynamic]Route)
}

@(private)
destroy_router :: proc(r : ^Router) {

    for &route in r.routes {
        delete(route.path)
    }

    delete(r.routes)
}
