void init() {
    var console = new Console("init");
    var projectName = console.question("Name");
    var author = console.question("Author");
    var website = console.question("Website");
    console.log(@"Initializing $projectName...");
    console.log("Building JSON");
    var pkg_builder = new Json.Builder();

    with(pkg_builder) {
        begin_object();
        set_member_name("name");
        add_string_value(projectName);
        set_member_name("author");
        add_string_value(author);
        set_member_name("website");
        add_string_value(website);
        set_member_name("dependencies");
        begin_array();
        end_array();
        end_object();
    }

    var generator = new Json.Generator();
    generator.set_root(pkg_builder.get_root());
    var pkg_json = generator.to_data(null);

    console.log("Generated JSON:");
    stdout.puts(pkg_json + "\n");
    var is_ok = console.question("Does this look OK");
    if(!(is_ok == "y" || is_ok == "Y")) {
        console.error("Exiting");
        return;
    }
    console.log("Writing package.json");
    var package_json = File.new_for_path("package.json");
    try {
        if(package_json.query_exists()) package_json.@delete();
        FileOutputStream os = package_json.create (FileCreateFlags.PRIVATE);
        size_t out_bytes;
        os.write_all(pkg_json.data, out out_bytes);
        os.close();
	} catch (Error e) {
        console.error(e.message);
        return;
	}

}