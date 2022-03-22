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

	public struct CompileResult {
		string outNames;
		CompileCommands.Command cmd;
	}

	class FileList : Gee.ArrayList<Files> {
		public int indexOfCompiler(Select.Compiler compiler) {
			var res = -1;
			this.@foreach((files) => {
				if(compiler.cmd == files.compiler.cmd) {
					res = this.index_of(files);
					return false;
				}
				return true;
			});
			return res;
		}
	}

	public CompileResult compile(string args, string file, Select.Compiler compiler, Console console, string log_file_name) throws Error {
		var message = @"Compiling $file with $(compiler.cmd)...";
		var files = file.split(" ");
		var nFiles = files.length;
		var outNames = compiler.outRule(file);
		if(nFiles > 1) message = @"Compiling $nFiles files with $(compiler.cmd)";
		var sp = Spinner.createAndStart(message, @"Compiled $(nFiles > 1 ? @"$nFiles files" : file) with $(compiler.cmd)");
		var cargs = new Gee.ArrayList<string>();
		cargs.add_all(new Gee.ArrayList<string>.wrap(compiler.cmd.split(" ")));
		cargs.add_all(new Gee.ArrayList<string>.wrap(args.split(" ")));
		cargs.add_all(new Gee.ArrayList<string>.wrap(files));
		cargs.add((string)0);
		for(int i = 0; i < cargs.size; i++) {
			if(cargs.@get(i) == " " || cargs.@get(i) == "") {
				cargs.remove_at(i);
			}
		}
		var cmd = new CompileCommands.Command() {
			file = files[0],
			directory = (string)vala_getcwd(),
			output = outNames.split(" ")[0],
			arguments = cargs.to_array()
		};
		var compile_output = Util.spawn_stdout_args(cargs.to_array());
		if(compile_output.status == 0) sp.stop();
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
		return CompileResult() {
			outNames = outNames,
			cmd = cmd
		};
	}

	private FileList sort(Gee.Iterable<string> files) {
		var sorted = new FileList();
		foreach(string file in files) {
			var compiler = Select.compiler(file);
			var index = sorted.indexOfCompiler(compiler);
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
		return sorted;
	}

	private Gee.ArrayList<string> compileFiles(FileList files, Gee.Iterable<string> pkgs, Gee.List<string> pkg_args, ref CompileCommands.Builder compile_commands, ValaConsole.Console console, string output_name) {
		var output = new Gee.ArrayList<string>();
		var intermediates = files;
		int compile_log_id = 0;
		while(intermediates.size > 0) {
			foreach(var entry in intermediates) {
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
					if(compiler.isVala) {
						var compileResult = compile(pkg_args_spaced, string.joinv(" ", entry.names.to_array()), compiler, console, @"compile.$output_name.$compile_log_id.log");
						var outFromVala = new Gee.ArrayList<string>.wrap(compileResult.outNames.replace("\n", "").split(" "));
						var sorted = sort(outFromVala);
						compile_commands.add(compileResult.cmd);
						intermediates.add_all(sorted);
					} else {
						foreach (var name in entry.names) {
							var result = compile(pkg_args_spaced, name, compiler, console, @"compile.$output_name.$compile_log_id.log");
							compile_commands.add(result.cmd);
							output.add_all(new Gee.ArrayList<string>.wrap(result.outNames.replace("\n", "").split(" ")));
						}
					}
				} catch(Error e) {
					print(@"\033[1;31m$(e.message)\033[0m]\n");
					Posix.exit(1);
				}
				compile_log_id++;
				intermediates.remove(entry);
			};
		}
		return output;
	}

	public CompileCommands.Builder compileAll(Gee.ArrayList<string> files, string output_name, Gee.ArrayList<string> base_pkgs) {
		var console = new Console("compile");
		var pkgs = new Gee.HashSet<string>();
		base_pkgs.@foreach(pkg => pkgs.add(pkg));
		var pkg_args = new Gee.ArrayList<string>();
		var compile_commands = new CompileCommands.Builder();
		try {
			foreach(string pkg in pkgs) {
				pkg_args.add_all(new Gee.ArrayList<string>.wrap(Util.spawn_stdout("pkg-config --libs --cflags " + pkg).stdout.replace("\n", "").split(" ")));
			}
		} catch(Error e) {
			console.error("Error running pkg-config");
		}
		var sorted = sort(files);
		var output = compileFiles(sorted, pkgs, pkg_args, ref compile_commands, console, output_name);
		var out_array = output.to_array();
		var sp = Spinner.createAndStart(@"Linking $output_name...");
		Util.Output link_output = Util.Output();
		var log = File.new_for_path(@"link.$output_name.log");
		try {
			log.@delete();
		} catch(Error e) {
		} finally {}
		try {
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
						try {
							size_t out_bytes;
							os.write_all("STDOUT\n------\n".data,               out out_bytes);
							os.write_all(link_output.stdout.data,               out out_bytes);
							os.write_all("\nSTDERR\n------\n".data,             out out_bytes);
							os.write_all(link_output.stderr.data,               out out_bytes);
							os.write_all("\nResult: Compilation FAILED\n".data, out out_bytes);
							os.close();
							print(@"\033[1;31mOutput has been written to \033[1mlink.$output_name.log\033[0;33m.\033[0m\n");
						} catch(IOError e) {
							console.error("Error writing link output");
						}
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
				} catch(Error e) {}
			}
		} catch(Error e) {}
		return compile_commands;
	}
}
