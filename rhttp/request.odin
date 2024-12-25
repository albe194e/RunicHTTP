package rhttp;

Request_method :: enum {
    GET
}

Request :: struct {

    method : Request_method,

    path : string

}

