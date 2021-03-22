namespace Valabuild {
	public string compile(string args, string file, Select.Compiler compiler, Console console) throws Error {
		console.log(file);
		var res = Posix.system(@"$(compiler.cmd) $args $file");
		if(res != 0) {
			throw new Error(Quark.from_string("compile"), res, "Failed compilation");
		}
		return compiler.outRule(file);
	}
	public void compileAll(Gee.ArrayList<string> files, string output_name, Gee.ArrayList<string> pkgs) {
		var console = new Console("compile");
		var sorted = new Gee.HashMap<Select.Compiler, Gee.ArrayList<string>>();
		var pkg_args = new Gee.ArrayList<string>();
		foreach(string pkg in pkgs) {
			pkg_args.add(Util.spawn_stdout("pkg-config --libs --cflags " + pkg));
		}
		foreach(string file in files) {
			var compiler = Select.compiler(file);
			if(sorted.has_key(compiler)) {
				sorted.@get(compiler).add(file);
			} else {
				var ar = new Gee.ArrayList<string>();
				ar.add(file);
				sorted.@set(compiler, ar);
			}
		}
		var output = new Gee.ArrayList<string>();
		sorted.@foreach((entry) => {
			var compiler = entry.key;
			try {
				var pkg_args_spaced = "";
				if(compiler.isVala) {
					foreach(string pkg in pkgs) {
						pkg_args_spaced += " --pkg=" + pkg;
					}
				} else {
					pkg_args_spaced = string.joinv(" ", pkg_args.to_array()).replace("\n", "");
				}
				output.add(compile(pkg_args_spaced, string.joinv(" ", entry.value.to_array()), compiler, console));
			} catch(Error e) {
				console.error("Compilation failed.");
				Posix.exit(1);
			}
			return true;
		});
		var out_array = output.to_array();
		console.log(@"LD " + output_name);
		Posix.system(@"gcc $(string.joinv(" ", pkg_args.to_array()).replace("\n", "")) -o " + output_name + " " + string.joinv(" ", out_array));
	}
}
