package main

import "core:fmt"
import "core:net"
import "core:strings"

import http "src"


main :: proc() {
    
    s : http.Server;
    http.init_server(&s)

    http.start_server(&s)
}
