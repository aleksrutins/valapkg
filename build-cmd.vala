void buildProject() {
	var console = new Console("build");
	var curPkg = Package.get_current();
	if(!curPkg.get_object().has_member("build")) {
		console.error("No build configuration found.");
		return;
	}
	console.log("Reading build configuration");
	var buildConf = curPkg.get_object().get_member("build");
	console.log("Fetching files from dependencies");
	var files = new Gee.ArrayList<string>();
	var deps = curPkg.get_object().get_array_member("dependencies");
	deps.foreach_element((arr, index, el) => {
		var parser = new Json.Parser();
		var filename = "modules/" + el.get_string().split("/")[1] + "/package.json";
		parser.load_from_file(filename);
		var pkg = parser.get_root();
		if(!pkg.get_object().has_member("build")) {
			console.log(@"No build configuration found for module $(el.get_object().get_string_member("name")). Skipping.");
			return;
		}
		pkg.get_object().get_object_member("build").get_array_member("files").foreach_element((_arr, _ind, el2) => {
			files.add("modules/" + el.get_string().split("/")[1] + "/" + el2.get_string());
		});
	});
	buildConf.get_object().get_array_member("files").foreach_element((_arr, _ind, file) => {
		files.add(file.get_string());
	});
	buildConf.get_object().get_array_member("targets").get_object_element(0).get_array_member("files").foreach_element((_arr, _ind, file) => {
		files.add(file.get_string());
	});
	var pkgs = new Gee.ArrayList<string>();
	if(buildConf.get_object().has_member("pkgs")) {
		var pkgs_json = buildConf.get_object().get_array_member("pkgs");
		pkgs_json.foreach_element((_arr, _ind, pkg) => {
			pkgs.add(pkg.get_string());
		});
	}
	Valabuild.compileAll(files, buildConf.get_object().get_array_member("targets").get_object_element(0).get_string_member("name"), pkgs);
}
