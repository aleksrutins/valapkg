using ValaConsole;
extern char *vala_getcwd();
delegate void DependenciesIterator(string dep);
void iterateDependenciesRecursive(DependenciesIterator cb) {
	var deps = getDeps();
	var rootCwd = (string)vala_getcwd();
	deps.@foreach((dep) => {
		cb(rootCwd + "/modules/" + dep);
		Posix.chdir("modules/" + dep);
		iterateDependenciesRecursive(cb);
		Posix.chdir(rootCwd);
		return true;
	});
}

Gee.ArrayList<string> getDeps() {
	var modulesFolder = File.new_for_path("modules");
	var modules = new Gee.ArrayList<string>();
	try {
		var iterator = modulesFolder.enumerate_children("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
		FileInfo info = null;
		while(((info = iterator.next_file()) != null)) {
			modules.add(info.get_name());
		}
	} catch(Error e) {}
	return modules;
}
void buildProject() throws GLib.Error {
	var console = new Console("build");
	var curPkg = Package.get_current();
	if(!curPkg.get_object().has_member("build")) {
		console.error("No build configuration found.");
		return;
	}

	console.log("Reading build configuration");
	var buildConf = curPkg.get_object().get_member("build");
	var targets = buildConf.get_object().get_array_member("targets");
	console.log(@"Targets: \033[1m$(targets.get_length())\033[0m");

	var compile_commands = new CompileCommands.Builder();

	targets.foreach_element((_arr_00, _ind_00, target) => {
		print(@"
--------
Building target \033[1m$(target.get_object().get_string_member("name"))\033[0m
--------
");

	    console.log("Fetching files from dependencies");
	    var files = new Gee.ArrayList<string>();
	    var pkgs = new Gee.ArrayList<string>();
	    if(buildConf.get_object().has_member("pkgs")) {
		    var pkgs_json = buildConf.get_object().get_array_member("pkgs");
		    pkgs_json.foreach_element((_arr, _ind, pkg) => {
			    pkgs.add(pkg.get_string());
		    });
	    }

	    iterateDependenciesRecursive((el) => {
		    var parser = new Json.Parser();
		    var filename = el + "/package.json";
			try {
				parser.load_from_file(filename);
				var pkg = parser.get_root();
				if(!pkg.get_object().has_member("build")) {
					console.log(@"No build configuration found for module $(el). Skipping.");
					return;
				}
				if(pkg.get_object().get_object_member("build").has_member("pkgs")) pkg.get_object().get_object_member("build").get_array_member("pkgs").foreach_element((_arr, _ind, el2) => {
					pkgs.add(el2.get_string());
				});
				if(pkg.get_object().get_object_member("build").has_member("files")) {
					pkg.get_object().get_object_member("build").get_array_member("files").foreach_element((_arr, _ind, el2) => {
						files.add(el + "/" + el2.get_string());
					});
				}
			} catch(Error e) {
				console.error("Error fetching files from dependencies");
			}
	    });

		if(buildConf.get_object().has_member("files")) {
			buildConf.get_object().get_array_member("files").foreach_element((_arr, _ind, file) => {
				files.add(file.get_string());
			});
		}
		if(target.get_object().has_member("files")) {
			target.get_object().get_array_member("files").foreach_element((_arr, _ind, file) => {
				files.add(file.get_string());
			});
		}

	    compile_commands.merge(Valabuild.compileAll(files, target.get_object().get_string_member("name"), pkgs));
	});

	var write_cc = Spinner.createAndStart("Writing compile_commands.json", "Wrote compile_commands.json");
	var file_cc = File.new_for_path("compile_commands.json");
	if(file_cc.query_exists()) file_cc.@delete();
	try {
		var stream = file_cc.create(PRIVATE);
		size_t out_bytes;
		stream.write_all(compile_commands.build().data, out out_bytes);
		write_cc.stop();
	} catch (Error e) {
		write_cc.stop("Failed to write compile_commands.json", true);
		printerr(e.message);
	}
}
