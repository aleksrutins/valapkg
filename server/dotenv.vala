namespace Dotenv {
    public void try_load() throws GLib.Error {
        var file = File.new_for_path(".env");
        if(!file.query_exists()) return;
        var contents = (string) Bytes.unref_to_data(file.load_bytes());
        if(contents == null) return;
        var lines = contents.split("\n");
        foreach(var line in lines) {
            var decl = line.split("=", 2);
            Environment.set_variable(decl[0], decl[1], false);
        }
    }
}