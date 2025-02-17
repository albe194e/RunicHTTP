package rhttp;

import "core:bytes"
import "core:strings"
import "core:fmt"
import "core:time"

Headers :: struct {
    kv : map[string]string
}

add_header :: proc(headers : ^Headers, k, v : string) {
    headers.kv[k] = v
}

@(private)
implicit_headers :: proc(r : ^Response) {

    //Content-length
    content_length := len(transmute([]byte)r.body.content)
    add_header(&r.headers, "Content-Length", fmt.aprintf("%i", content_length))

    //Date
    //TODO: Properly format date and rewrite code so server calculates date occationaly to increase speed.
    date_time := time.now()
    date_buff : [120]u8
    //r.headers.kv["Date"] = strings.clone(time.to_string_dd_mm_yy(date_time, date_buff[:]))

    //Content-type
    add_header(&r.headers, "Content-Type", fmt.aprintf("application/%v", content_type_to_str(r.settings.content_type)))

    //Server
    add_header(&r.headers, "Server", "RunicHttp/0.0.1")
}
