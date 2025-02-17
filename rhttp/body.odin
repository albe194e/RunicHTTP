package rhttp;

import "core:fmt"
import "core:encoding/json"
import "core:strings"

Types :: union {
    string,
    int,
    bool,
    f32
}

Json_body :: struct {

    kv : map[string]Types
}

build_json_body :: proc (a : any) -> []byte {

    fmt.printfln("To_Marshal: %#v", a)

    if a == nil {     
        return nil;
    }

    data, err := json.marshal(a)

    if err == nil {
        panic("Could not marshal object")
    }

    return data;
}

parse_json_body :: proc (b : Json_body) {
    body_str := make([dynamic]string)
    defer delete(body_str)

}

init_json_body :: proc (b : ^Json_body) {
    b.kv = make(map[string]Types)
}

delete_json_body :: proc (b : ^Json_body) {
    delete(b.kv)
}