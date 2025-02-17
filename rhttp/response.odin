package rhttp;

import "core:fmt"
import "core:strings"
import "core:bytes"
import "core:reflect"

Response :: struct {

    status_line : Status_line,
    headers : Headers,
    settings : Response_settings,
    body : Response_body
}

Response_body :: struct {
    content : string
}

Status_line :: struct {

    version : string,
    status : Response_status
}

Response_status :: struct {
    code : Status_code,
    desc : string
}

Response_settings :: struct {
    content_type : Content_type
}

//Determines what format should be build
Content_type :: enum {
    NONE,
    JSON,
    XML
}

parse_response :: proc(r : ^Response, err : RhttpError) -> []byte {

    //Add standard headers
    implicit_headers(r)

    fmt.printfln("HEADERS: %#v", r.headers)

    to_concat := make([dynamic]string)
    defer delete(to_concat)

    ok := check_response(r^)

    //Status line
    append(&to_concat, strings.concatenate({
        r.status_line.version,
        " ", 
        convert_status_code_to_str(r.status_line.status.code), 
        "\r\n"}));

    if ok {
        
    }
    
    //Headers
    for k, v in r.headers.kv {
        append(&to_concat, strings.concatenate({k, ": ", v, "\r\n"}));
    }

    append(&to_concat, "\r\n")

    //Body
    //body := build_json_body(r.body.content)
    body := transmute([]byte)r.body.content

    response := transmute([]byte)strings.concatenate(to_concat[:])

    return bytes.concatenate({response, body})
}

@(private="file")
check_response :: proc(r : Response) -> (ok : bool) {

    if cast(u16)r.status_line.status.code < 400 {
        ok = true
    }

    return ok;
}


init_response :: proc(r : ^Response) {

    r.status_line.version = "HTTP/1.1"
}

destroy_response :: proc(r : ^Response) {

    delete(r.headers.kv)
}

@(private)
content_type_to_str :: proc(ct : Content_type) -> string {

    enum_str, ok := reflect.enum_name_from_value(ct)

    if !ok {
        fmt.panicf("Could not parse content_type: %v ", ct)
    }

    return strings.to_lower(enum_str)
}
