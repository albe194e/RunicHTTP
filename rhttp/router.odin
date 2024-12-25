package rhttp;

action :: #type proc() -> []byte;

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
