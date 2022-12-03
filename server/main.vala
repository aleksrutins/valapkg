void main() {
    var console = new ValaConsole.Console("server");
    var server = (Soup.Server)Object.new(typeof(Soup.Server));

    server.add_handler("/", (server, msg, path, query) => {
        msg.set_status(200, "OK");
        var body = "Hello World";
        msg.set_response("text/html", Soup.MemoryUse.COPY, body.data);
    });

    try {
        var main_loop = new MainLoop(null, false);
        server.listen_all(int.parse(Environment.get_variable("PORT") ?? "8080"), Soup.ServerListenOptions.IPV6_ONLY);
        console.log(@"Listening on port $(Environment.get_variable("PORT") ?? "8080")");
        main_loop.run();
    } catch(Error e) {
        console.error(e.message);
    }
}
