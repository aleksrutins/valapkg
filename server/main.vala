using Valapkg.Server;
using Valapkg.Server.DB;

string read_file(File file) throws GLib.Error {
    var istream = file.read();
    istream.seek(0, SeekType.END);
    var buffer = new uint8[istream.tell()];
    istream.seek(0, SeekType.SET);
    size_t len;
    istream.read_all(buffer, out len);
    return (string)buffer;
}

int main() {
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

        var relative_path = path.length == 1 ? "" : path.slice(1, path.length);
        if(relative_path == "" || !File.new_for_path(relative_path).query_exists(null))
            relative_path = "index.html";

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
