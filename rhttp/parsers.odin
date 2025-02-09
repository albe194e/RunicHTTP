package rhttp;

import "core:fmt"
import "core:strings"
import "core:bytes"
import "core:slice"

@(private)
parse_request :: proc(data : string) -> (r : Request) {

    init_request(&r);

    data, was_alloc := strings.replace_all(data, "\r\n", "\n");
    defer {if was_alloc {delete(data)}};
    
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
    fmt.printf("Tokens: %#v", tokens)

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
                    panic("Invalid method");
                }
            
            case .path:
                r.rl.path = tokens[i].value;
                state = .version;
            
            case .version:
                r.rl.version = tokens[i].value;
                state = .headers;
    
            case .headers:

                if tokens[i + 1].value != ":" {
                    state = .body
                    continue;
                }
                r.headers.kv[tokens[i].value] = tokens[i + 2].value;
                i += 2;

            case .body:
                return

        }
    }


    /*


    //Get headers
    header_byte_seperator := transmute([]byte)HEADER_SEPERATOR_S;
    data_split := bytes.split_after(data, header_byte_seperator);

    headers := data_split[0][:]
    //Get necessary data from headers
    method_path := bytes.split(headers, {BACKSLASH});
    method := method_path[0][:]
    path := bytes.split(method_path[1][:], {SPACE})[0][:];
    
    r.method = string_to_request_method(strings.clone_from_bytes(method));
    r.path = fmt.aprintf("/%v",strings.clone_from_bytes(path));

    fmt.printfln("Showing: %#v", strings.clone_from_bytes(data_split[0][:]))
    return r;
    */

    return r;
}

@(private)
parse_response :: proc(r : string) -> (b : []byte) {

    return transmute([]byte)r
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
