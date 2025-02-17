package rhttp;

import "core:fmt"
import "core:strings"
import "core:bytes"
import "core:slice"

@(private)
parse_request :: proc(data : string) -> (r : Request, err : RhttpError) {

    //fmt.printfln("Req: %#v", data)
    data, was_alloc := strings.replace_all(data, "\r\n", "\n");
    defer {if was_alloc {delete(data)}};

    //Seperate body from request
    split_req := strings.split_after(data, "\n\n")
    
    if (len(split_req) > 2) {
        err.message =  fmt.tprintf("Something is wrong with the request: %#v", split_req);
        err.status = .Internal_Server_Error
        return r, err,
    }
    
    Token :: struct {
        value : string
    };
    
    tokens := make([dynamic]Token)
    defer delete(tokens)

    current_index : int;
    
    for r, i in data {
        switch r {
            case ' ', '\n':
                if current_index != i {
                    append(&tokens, Token{data[current_index:i]})
                }
                current_index = i + 1;
            case ':':
                append(&tokens, Token{data[current_index:i]})
                append(&tokens, Token{data[i:i+1]})
                current_index = i + 1;
        }
    }
    //fmt.printf("Tokens: %#v", tokens)

    state : enum {
        method,
        path,
        version,
        headers,
        body
    }

    for i := 0; i < len(tokens); i += 1 {

        switch state {
            case .method:
                m := string_to_request_method(tokens[i].value)
                if m != .NONE {
                    r.rl.method = m;
                    state = .path
                }
                else {
                    err.message = fmt.tprintfln("Requested method is not supported. Current supported methods are: %v", SUPPORTED_METHODS)
                }
            
            case .version:
                r.rl.version = tokens[i].value;
                state = .headers;
            case .path:
                r.rl.path = strings.clone(tokens[i].value);
                state = .version;
            
    
            case .headers:
                
                //TODO: Extract headers correctly
                if tokens[i + 1].value != ":" {
                    state = .body
                    continue;
                }

                r.headers.kv[tokens[i].value] = tokens[i + 2].value;
                i += 2;

            case .body:
                r.body = strings.clone(split_req[1])                
        }
    }

    return r, err;
}

//Helpers 
@(private="file")
string_to_request_method :: proc(s : string) -> Request_method {

    switch (s) {
        case "GET":
            return .GET
        case :
            return .NONE
    }
}
