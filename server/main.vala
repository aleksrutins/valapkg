using Valapkg.Server;
using Valapkg.Server.DB;

int main() {
    var console = new ValaConsole.Console("server");
    var server = (Soup.Server)Object.new(typeof(Soup.Server));

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
        var body = "Hello World";
        msg.set_response("text/html", Soup.MemoryUse.COPY, body.data);
    });

    server.add_handler("/another-thing", (server, msg, path, query) => {
        msg.set_status(200, "OK");
        var body = "Hello World, another thing";
        msg.set_response("text/html", Soup.MemoryUse.COPY, body.data);
    });

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
