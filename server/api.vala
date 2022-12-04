using Valapkg.Server.DB;

namespace Valapkg.Server.API {
    class Release : Object {
        public string owner {get; set;}
        public string package {get; set;}
        public string version {get; set;}
        public string source {get; set;}
        public Release.from_pg(Postgres.Result res, int row_num) {
            owner =   res.get_value(row_num, 0);
            package = res.get_value(row_num, 1);
            version = res.get_value(row_num, 2);
            source =  res.get_value(row_num, 3);
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

    void api_handler(Soup.Server server, Soup.ServerMessage msg, string path, HashTable<string, string>? query) {
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

        else {
            msg.set_status(404, "Not Found");
            msg.set_response("application/json", Soup.MemoryUse.STATIC, "{\"status\": 404, \"error\": \"Not Found\"}".data);
        }
    }
}