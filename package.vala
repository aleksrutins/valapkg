namespace Package {
    Json.Node get_current() {
        var parser = new Json.Parser();
        parser.load_from_file("package.json");
        return parser.get_root();
    }
    void write(Json.Node obj) {
        var gen = new Json.Generator();
        gen.set_root(obj);
        var package_json = File.new_for_path("package.json");
        if(package_json.query_exists()) package_json.@delete();
        FileOutputStream os = package_json.create (FileCreateFlags.PRIVATE);
        size_t out_bytes;
        os.write_all(pkg_json.data, out out_bytes);
        os.close();
    }
    void install(string name) {
        bool use_branch = false;
        string branch = "master";
        string repo = name;
        string pkg_name = "";
        Json.Node pkg_json = null;
        var console = new Console("package/install");
        if(name.contains("@")) { 
            branch = name.split("@")[1];
            repo = name.split("@")[0];
        }
        pkg_name = repo.split("/")[1];
        var session = new Soup.Session();
        var msg = new Soup.Message("GET", @"https://github.com/$repo/$branch/package.json");
        session.send(msg);
        if(msg.status_code == 200) {
            var parser = new Json.Parser();
            parser.load_from_data(msg.response_body.data);
            pkg_json = parser.get_root();
            pkg_name = pkg_json.get_object().get_string_member("name");
        } else {
            console.log("Not using package.json");
        }
        Posix.system(@"git clone https://github.com/$repo.git -b $branch");
    }
}