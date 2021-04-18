using ValaConsole;
namespace Valabuild {
	class Files {
		public Gee.ArrayList<string> names;
		public Select.Compiler compiler;
		public Files(Select.Compiler compiler) {
			this.compiler = compiler;
			this.names = new Gee.ArrayList<string>();
		}
	}
	class FileList : Gee.ArrayList<Files> {
		public static int has(FileList _self, Select.Compiler compiler) {
			var res = -1;
			_self.@foreach((files) => {
				if(compiler.cmd == files.compiler.cmd) {
					res = _self.index_of(files);
					return false;
				}
				return true;
			});
			return res;
		}
	}
	public string compile(string args, string file, Select.Compiler compiler, Console console) throws Error {
		var sp = Spinner.createAndStart(@"Compiling with $(compiler.cmd)...", @"Compiled $file");
		var res = Posix.system(@"$(compiler.cmd) $args $file");
		if(res == 0) sp.stop(@"Compiled $file");
		else sp.stop("Failed compilation", true);
		if(res != 0) {
			throw new Error(Quark.from_string("compile"), res, "Failed compilation");
		}
		return compiler.outRule(file);
	}
	public void compileAll(Gee.ArrayList<string> files, string output_name, Gee.ArrayList<string> pkgs) {
		var console = new Console("compile");
		var sorted = new FileList();
		var pkg_args = new Gee.ArrayList<string>();
		foreach(string pkg in pkgs) {
			pkg_args.add(Util.spawn_stdout("pkg-config --libs --cflags " + pkg));
		}
		foreach(string file in files) {
			var compiler = Select.compiler(file);
			var index = FileList.has(sorted, compiler);
			if(index >= 0) {
				var files_obj = sorted.@get(index);
				files_obj.names.add(file);
			} else {
				var ar = new Gee.ArrayList<string>();
				ar.add(file);
				var files_obj = new Files(compiler);
				files_obj.names = ar;
				sorted.add(files_obj);
			}
		}
		var output = new Gee.ArrayList<string>();
		sorted.@foreach((entry) => {
			var compiler = entry.compiler;
			try {
				var pkg_args_spaced = "";
				if(compiler.isVala) {
					foreach(string pkg in pkgs) {
						pkg_args_spaced += " --pkg=" + pkg;
					}
				} else {
					pkg_args_spaced = string.joinv(" ", pkg_args.to_array()).replace("\n", "");
				}
				output.add(compile(pkg_args_spaced, string.joinv(" ", entry.names.to_array()), compiler, console));
			} catch(Error e) {
				Posix.exit(1);
			}
			return true;
		});
		var out_array = output.to_array();
		var sp = Spinner.createAndStart(@"Linking $output_name...");
		var res = Posix.system(@"gcc $(string.joinv(" ", pkg_args.to_array()).replace("\n", "")) -o " + output_name + " " + string.joinv(" ", out_array));
		if(res != 0) {
			sp.stop(@"Failed to link $(string.joinv(" ", out_array)) \u2192 $output_name", true);
		} else {
			sp.stop(@"Linked $(string.joinv(" ", out_array)) \u2192 $output_name");
		}
	}
}
