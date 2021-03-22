namespace Package {
    Json.Node get_current() throws Error {
        var parser = new Json.Parser();
        parser.load_from_file("package.json");
        return parser.get_root();
    }
    void write(Json.Node obj) throws Error {
        var gen = new Json.Generator();
        gen.set_root(obj);
        gen.pretty = true;
        var package_json = File.new_for_path("package.json");
        if(package_json.query_exists()) package_json.@delete();
        FileOutputStream os = package_json.create (FileCreateFlags.PRIVATE);
        size_t out_bytes;
        os.write_all(gen.to_data(null).data, out out_bytes);
        os.close();
    }
    string install(string name) {
        bool use_branch = false;
        string branch = "master";
        string repo = name;
        string pkg_name = "";
        Json.Node pkg_json = null;
        var console = new Console("package/install");
        if(name.contains("@")) { 
            branch = name.split("@")[1];
            console.log(@"Branch: $branch");
            repo = name.split("@")[0];
            console.log(@"Repo: $repo");
        }
        pkg_name = repo.split("/")[1];
        console.log(@"Package name: $pkg_name");
        Posix.system("mkdir -p modules");
        console.log(@"Running: git submodule add -b $branch git://github.com/$repo.git modules/$pkg_name");
        Posix.system(@"git submodule add -b $branch git://github.com/$repo.git modules/$pkg_name");
        return pkg_name;
    }
}