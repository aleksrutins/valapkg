using Valapkg.Server.DB;

namespace Valapkg.Server.API {

    class ReleaseIdentifier : Object {
        public string owner {get; set;}
        public string package {get; set;}
        public string version {get; set;}

        public ReleaseIdentifier.from_values(string owner, string package, string version) {
            this.owner = owner;
            this.package = package;
            this.version = version;
        }

        public ReleaseIdentifier.from_string(string resolver) throws Error {
            var regex = new Regex("""^(\S*)\/(\S*)\@([.\S]*)$""", RegexCompileFlags.UNGREEDY, 0);
            MatchInfo matched;
            if(!regex.match(resolver, 0, out matched)) {
                throw new Error(Quark.from_string("invalid-semver"), 1, @"Invalid semver identifier: $(resolver)");
            }
            owner = matched.fetch(1);
            package = matched.fetch(2);
            version = matched.fetch(3);
        }

        public ReleaseIdentifier.from_pg(Postgres.Result res, int row_num) {
            owner =   res.get_value(row_num, 0);
            package = res.get_value(row_num, 1);
            version = res.get_value(row_num, 2);
        }

        public string to_string() {
            return @"$(owner)/$(package)@$(version)";
        }
    }

    class Release : Object {
        public ReleaseIdentifier ident {get; set;}
        public string source {get; set;}
        public Release.from_pg(Postgres.Result res, int row_num) {
            ident =  new ReleaseIdentifier.from_pg(res, row_num);
            source = res.get_value(row_num, 3);
        }
        public Prosody.Data.Data to_data() {
            var map = new Gee.HashMap<Slice, Prosody.Data.Data>();
            map.set(new Slice.s("owner"), new Prosody.Data.Literal(ident.owner));
            return new Prosody.Data.Mapping(map);
        }
    }

    class Dependency : Object {
        string from_owner;
        string from_package;
        string from_version;
        string to_owner;
        string to_package;
        string to_version;
        public Dependency.from_pg(Postgres.Result res, int row_num) {
            from_owner =   res.get_value(row_num, 0);
            from_package = res.get_value(row_num, 1);
            from_version = res.get_value(row_num, 2);
            to_owner =     res.get_value(row_num, 3);
            to_package =   res.get_value(row_num, 4);
            to_version =   res.get_value(row_num, 5);
        }
    }

    Gee.ArrayList<Release> all_releases() {
        var releases = new Gee.ArrayList<Release>();
        var result = global_db.exec_prepared("get_releases", 0, null, null, null, 0);
        var length = result.get_n_tuples();
        for(var row = 0; row < length; row++) {
            releases.add(new Release.from_pg(result, row));
        }
        return releases;
    }

    Gee.ArrayList<ReleaseIdentifier> get_dependencies(ReleaseIdentifier of) {
        var deps = new Gee.ArrayList<ReleaseIdentifier>();
        var result = global_db.exec_prepared("get_dependencies", 3, {of.owner, of.package, of.version}, null, null, 0);
        var length = result.get_n_tuples();
        for(var row = 0; row < length; row++) {
            deps.add(new ReleaseIdentifier.from_pg(result, row));
        }
        return deps;
    }

    void send_error(Soup.ServerMessage msg, int code, string error) {
        msg.set_status(code, error);
        msg.set_response("application/json", Soup.MemoryUse.COPY, @"{\"status\": $(code), \"error\": \"$(error)\"}".data);
    }

    void api_handler(Soup.Server server, Soup.ServerMessage msg, string path, HashTable<string, string>? query) {
        try {
            if(path == "/api/releases") {
                msg.set_status(200, "OK");
                var releases = all_releases();
                var arr = new Json.Node(Json.NodeType.ARRAY);
                arr.set_array(new Json.Array());
                foreach(var release in releases) {
                    arr.get_array().add_element(Json.gobject_serialize(release));
                }
                var response_body = Json.to_string(arr, false);
                msg.set_response("application/json", Soup.MemoryUse.COPY, response_body.data);
            }

            else if (path == "/api/releases/dependencies") {
                if(query == null || !query.contains("pkg")) {
                    send_error(msg, 400, "Invalid Request");
                }

                var ident = new ReleaseIdentifier.from_string(query.get("pkg"));
                var deps = get_dependencies(ident);
                var arr = new Json.Node(Json.NodeType.ARRAY);
                arr.set_array(new Json.Array());
                foreach(var dep in deps) {
                    arr.get_array().add_element(Json.gobject_serialize(dep));
                }
                var response_body = Json.to_string(arr, false);
                msg.set_response("application/json", Soup.MemoryUse.COPY, response_body.data);
            }

            else {
                send_error(msg, 404, "Not Found");    
            }
        } catch(Error e) {
            send_error(msg, 500, "Internal Server Error");
            (new ValaConsole.Console("api")).error(e.message);
        }
    }
}