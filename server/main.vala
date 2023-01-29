using Valapkg.Server;
using Valapkg.Server.DB;
using Prosody;

string read_file(File file) throws GLib.Error {
    var istream = file.read();
    istream.seek(0, SeekType.END);
    var buffer = new uint8[istream.tell()];
    istream.seek(0, SeekType.SET);
    size_t len;
    istream.read_all(buffer, out len);
    return (string)buffer;
}

Json.Array list_to_json(Gee.List<Object> list) {
    var arr = new Json.Array.sized(list.size);
    foreach(var item in list) {
        arr.add_element(Json.gobject_serialize(item));
    }
    return arr;
}

/** Render a template. RETURN IMMEDIATELY FROM THE HANDLER AFTER CALLING THIS! */
void render_template(Soup.ServerMessage msg, string name, Json.Node json_data, ref Prosody.ErrorData? error_data) throws Error {
    var template = Prosody.get_for_path("templates/index.html", ref error_data);
    var writer = new Prosody.CaptureWriter();
    template.exec.begin(xJSON.build(json_data), writer, () => {
        msg.set_response("text/html", Soup.MemoryUse.COPY, writer.grab_string().data);
        msg.unpause();
    });
    msg.pause();
}

Gee.List<T> iterator_to_list<T>(Gee.Iterator<T> iter) {
    var list = new Gee.LinkedList<T>();
    for(var item = iter.get(); iter.next(); item = iter.get()) {
        list.add(item);
    }
    return list;
}

class IndexData : Object {
    public Gee.List<API.Release> releases {get; set;}
}

int main() {

    Dotenv.try_load();

    Std.register_standard_library();
    var console = new ValaConsole.Console("server");
    var server = (Soup.Server)Object.new(typeof(Soup.Server));

    var mime_types = new Gee.HashMap<string, string>();
    mime_types["json"] = "application/json";
    mime_types["html"] = "text/html";
    mime_types["js"] = "text/javascript";
    mime_types["css"] = "text/css";

    console.log("Connecting to database...");
    var conn_url = Environment.get_variable("DATABASE_URL");
    if(conn_url == null) {
        console.error("Please provide a $DATABASE_URL.");
        return 1;
    }
    global_db = Postgres.connect_db(conn_url);
    console.log("Database connected!");
    console.log("Preparing queries...");
    prepare_queries();

    server.request_finished.connect(msg => {
        console.log(@"$(msg.get_method()) $(msg.get_uri().get_path()) $(msg.get_status())");
    });
    server.add_handler("/", (server, msg, path, query) => {
        msg.set_status(200, "OK");

        try {
            if(path == "/") {
                Prosody.ErrorData error_data = null;
                var release_list = API.all_releases();
                var list_data = list_to_json(release_list);
                var map = new Json.Object();
                map.set_array_member("releases", list_data);
                render_template(msg, "templates/index.html", new Json.Node.alloc().init_object(map), ref error_data);
                return;
            }
        } catch(Error e) {
            console.error(e.message);
            API.send_error(msg, 500, "Internal Server Error");
            return;
        }

        var relative_path = path.length == 1 ? "" : path.slice(1, path.length);
        if(relative_path == "" || !File.new_for_path(relative_path).query_exists(null)) {
            msg.set_status(404, "Not Found");
            relative_path = "404.html";
        }

        console.log(@"Serve static $(relative_path)");
        var file = File.new_for_path("static/" + relative_path);
        string result = "";
        try {
            result = read_file(file);
        } catch(Error e) {
            console.error(e.message);
            API.send_error(msg, 500, "Internal Server Error");
            return;
        }
        string content_type = "";
        var filename_parts = relative_path.split(".");
        if(mime_types.has_key(filename_parts[filename_parts.length-1]))
            content_type = mime_types[filename_parts[filename_parts.length-1]];
        else
            content_type = "text/plain";
        msg.set_response(content_type, Soup.MemoryUse.COPY, result.data);
    });

    server.add_handler("/api", API.api_handler);

    try {
        var main_loop = new MainLoop(null, false);
        server.listen_all(int.parse(Environment.get_variable("PORT") ?? "8080"), Soup.ServerListenOptions.IPV4_ONLY);
        console.log(@"Listening on port $(Environment.get_variable("PORT") ?? "8080")");
        main_loop.run();
    } catch(Error e) {
        console.error(e.message);
        return 1;
    }
    return 0;
}
