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
	public string compile(string args, string file, Select.Compiler compiler, Console console, string log_file_name) throws Error {
		var sp = Spinner.createAndStart(@"Compiling with $(compiler.cmd)...", @"Compiled $file");
		var cargs = new Gee.ArrayList<string>();
		cargs.add_all(new Gee.ArrayList<string>.wrap(compiler.cmd.split(" ")));
		cargs.add_all(new Gee.ArrayList<string>.wrap(args.split(" ")));
		cargs.add_all(new Gee.ArrayList<string>.wrap(file.split(" ")));
		cargs.add((string)0);
		for(int i = 0; i < cargs.size; i++) {
			if(cargs.@get(i) == " " || cargs.@get(i) == "") {
				cargs.remove_at(i);
			}
		}
		var compile_output = Util.spawn_stdout_args(cargs.to_array());
		if(compile_output.status == 0) sp.stop(@"Compiled with $(compiler.cmd)");
		else sp.stop("Failed compilation", true);
		if(compile_output.stderr.length > 0 || compile_output.stdout.length > 0) {
			var log = File.new_for_path(log_file_name);
			try {
				log.@delete();
			} catch(Error e) {
			} finally {}
			FileOutputStream os = log.create(FileCreateFlags.PRIVATE);
			size_t out_bytes;
			try {
				os.write_all("STDOUT\n------\n".data,                  out out_bytes);
				os.write_all(compile_output.stdout.data,               out out_bytes);
				os.write_all("\nSTDERR\n------\n".data,                out out_bytes);
				os.write_all(compile_output.stderr.data,               out out_bytes);
			} finally {try {os.close();} catch(Error e) {}}
			print(@"\033[33mOutput has been written to \033[1m$log_file_name\033[0;33m.\033[0m\n");
		}
		if(compile_output.status != 0) {
			throw new Error(Quark.from_string("compile"), compile_output.status, "Failed compilation");
		}
		return compiler.outRule(file);
	}
	public void compileAll(Gee.ArrayList<string> files, string output_name, Gee.ArrayList<string> base_pkgs) {
		var console = new Console("compile");
		var sorted = new FileList();
		var pkgs = new Gee.HashSet<string>();
		base_pkgs.@foreach(pkg => pkgs.add(pkg));
		var pkg_args = new Gee.ArrayList<string>();
		foreach(string pkg in pkgs) {
			pkg_args.add_all(new Gee.ArrayList<string>.wrap(Util.spawn_stdout("pkg-config --libs --cflags " + pkg).stdout.replace("\n", "").split(" ")));
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
		int compile_log_id = 0;
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
				output.add_all(new Gee.ArrayList<string>.wrap(compile(pkg_args_spaced, string.joinv(" ", entry.names.to_array()), compiler, console, @"compile.$output_name.$compile_log_id.log").replace("\n", "").split(" ")));
			} catch(Error e) {
				print(@"\033[1;31m$(e.message)\033[0m]\n");
				Posix.exit(1);
			}
			compile_log_id++;
			return true;
		});
		var out_array = output.to_array();
		var sp = Spinner.createAndStart(@"Linking $output_name...");
		Util.Output link_output = Util.Output();
		var log = File.new_for_path(@"link.$output_name.log");
		try {
			log.@delete();
		} catch(Error e) {
		} finally {}
		FileOutputStream os = log.create(FileCreateFlags.PRIVATE);
		try {
			var args = new Gee.ArrayList<string>();
			args.add("gcc");
			args.add_all(pkg_args);
			args.add("-o");
			args.add(output_name);
			args.add_all(new Gee.ArrayList<string>.wrap(out_array));
			args.add((string)0);
			for(int i = 0; i < args.size; i++) {
				if(args.@get(i) == " " || args.@get(i) == "") args.remove_at(i);
			}
			link_output = Util.spawn_stdout_args(args.to_array());
			if(link_output.status != 0) {
				throw new Error(Quark.from_string("compile"), link_output.status, "Failed to link");
			}
			sp.stop(@"Linked $output_name");
			if(link_output.stderr.length > 0 || link_output.stdout.length > 0) {
				size_t out_bytes;
				os.write_all("STDOUT\n------\n".data,                  out out_bytes);
				os.write_all(link_output.stdout.data,                  out out_bytes);
				os.write_all("\nSTDERR\n------\n".data,                out out_bytes);
				os.write_all(link_output.stderr.data,                  out out_bytes);
				os.write_all("\nResult: Compilation SUCCEEDED\n".data, out out_bytes);
				os.close();
				print(@"\033[33mOutput has been written to \033[1mlink.$output_name.log\033[0;33m.\033[0m\n");
			}
		} catch(Error e) {
			sp.stop(@"Failed to link $output_name", true);
			if(link_output.stdout != null && link_output.stderr != null) {
				if(link_output.stderr.length > 0 || link_output.stdout.length > 0) {
					size_t out_bytes;
					os.write_all("STDOUT\n------\n".data,               out out_bytes);
					os.write_all(link_output.stdout.data,               out out_bytes);
					os.write_all("\nSTDERR\n------\n".data,             out out_bytes);
					os.write_all(link_output.stderr.data,               out out_bytes);
					os.write_all("\nResult: Compilation FAILED\n".data, out out_bytes);
					os.close();
					print(@"\033[1;31mOutput has been written to \033[1mlink.$output_name.log\033[0;33m.\033[0m\n");
				} else {
					print("\033[1;31mNo output.\033[0m\n");
				}
			} else {
				print("\033[1;31mProcess spawn failed\033[0m\n");
				print(e.message + "\n");
			}
		} finally {
			try {
				os.close();
			} catch(Error e) {} finally {}
		}
	}
}
