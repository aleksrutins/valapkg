using ValaConsole;
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
        string branch = "master";
        string repo = name;
        string pkg_name = "";
        var console = new Console("package/install");
        if(name.contains("@")) { 
            branch = name.split("@")[1];
            repo = name.split("@")[0];
        }
        pkg_name = repo.split("/")[1];
        Posix.system("mkdir -p modules");
        try {
            var sp = Spinner.createAndStart(@"Cloning repository $repo...");
            Util.spawn_stdout_v("git", "submodule", "add", "-b", branch, @"git://github.com/$repo.git", @"modules/$pkg_name");
            sp.stop(@"Cloned $repo in modules/$pkg_name.");
        } catch (Error e) {
            console.error("An error occured when cloning. Please make sure the repo exists and you have Git installed.");
        }
        return pkg_name;
    }
}