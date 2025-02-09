package rhttp;

import "core:fmt"
import "core:strings"

Response :: struct {

    status_line : Status_line,
    headers : map[string]string,
    body : Response_body
}

Response_body :: struct {
    content : string
}

Status_line :: struct {

    version : string,
    status_code : Status_code,
    desc : string
}

build_response :: proc(r : Response) -> string {

    to_concat := make([dynamic]string)
    defer delete(to_concat)

    //Status line
    append(&to_concat, strings.concatenate({
        r.status_line.version,
        " ", 
        convert_status_code_to_str(r.status_line.status_code), 
        "\r\n"}));
    
    //Headers
    for k, v in r.headers {
        append(&to_concat, strings.concatenate({k, ": ", v, "\r\n"}));
    }

    //Body
    append(&to_concat, strings.concatenate({"\r\n", r.body.content}))

    build_resp := strings.concatenate(to_concat[:])

    return build_resp
}

init_response :: proc(r : ^Response) {

    r.headers = make(map[string]string);
    r.status_line.version = "HTTP/1.1"
}

destroy_response :: proc(r : ^Response) {

    delete(r.headers)
}
