package http;

import "core:net"
import "core:os"
import "core:fmt"
import "core:encoding/json"
import "core:reflect"

Server_config :: struct {
    port: int,
    url: string,
}

Config_type_e :: enum {
    SERVER,
}

Config_type_u :: union {
    Server_config,
}

load_config_from_file :: proc(path : string, type : Config_type_e) -> (config : Config_type_u) {

    //Find type & initialize with defualt configurations
    #partial switch type {
        case .SERVER:
            config = defualt_server_config;
            break;
        case:
            panic("That config type does not exist")
        }
            
    //Load saved JSON data
    data, ok_file := os.read_entire_file_from_filename(path);
    defer delete(data);

	if ok_file {

        json_data, _ := json.parse(data);

        //Check if json field corrosponds with config type struct
        struct_fields := reflect.struct_field_names(reflect.union_variant_typeid(config))
        for json_field in json_data.(json.Object) {
            field_exists : bool
            for sf in struct_fields {
                if json_field == sf {
                    field_exists = true;
                }
            }
            if !field_exists {
                fmt.panicf("Json field: %#v does does not exist in config type: %#v\n", json_field, type)
            }
        }
		err := json.unmarshal(data, &config);
		if err != nil {
            panic("Failed to load config")
		} else {
			fmt.printf("\nSuccesfully loaded config file: %#v\n", config)
		}
	} else {
        fmt.panicf("Failed to load configuration file: %#v", path)
    }

    return config
}
