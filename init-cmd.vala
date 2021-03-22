void init() {
    var console = new Console("init");
    var projectName = console.question("Name");
    var author = console.question("Author");
    var website = console.question("Website");
    console.log(@"Initializing $projectName...");
    console.log("Building JSON");
    var pkg_builder = new Json.Builder();

    pkg_builder.begin_object();
    pkg_builder.set_member_name("name");
    pkg_builder.add_string_value(projectName);
    pkg_builder.set_member_name("author");
    pkg_builder.add_string_value(author);
    pkg_builder.set_member_name("website");
    pkg_builder.add_string_value(website);
    pkg_builder.set_member_name("dependencies");
    pkg_builder.begin_array();
    pkg_builder.end_array();
    pkg_builder.end_object();

    var generator = new Json.Generator();
    generator.set_root(pkg_builder.get_root());
    generator.pretty = true;
    var pkg_json = generator.to_data(null);

    console.log("Generated JSON:");
    stdout.puts(pkg_json + "\n");
    var is_ok = console.question("Does this look OK");
    if(!(is_ok == "y" || is_ok == "Y")) {
        console.error("Exiting");
        return;
    }
    console.log("Writing package.json");
    try {
        Package.write(pkg_builder.get_root());
	} catch (Error e) {
        console.error(e.message);
        return;
	}
    try {
        console.log("Initializing with Git");
        Util.spawn_stdout("git init");
        Util.spawn_stdout("git add -A");
        console.log("Creating initial commit");
        Util.spawn_stdout_v("git", "commit", "-m", "Initial commit");
        console.log("Done!");
    } catch(Error e) {
        console.error("An error occured. Please make sure you have Git installed.");
        return;
    }
}