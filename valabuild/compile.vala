namespace Valabuild {
	public string compile(string file, Select.Compiler compiler, Console console) {
		console.log(file);
		Posix.system(@"$(compiler.cmd) $file");
		return compiler.outRule(file);
	}
	public void compileAll(Gee.ArrayList<string> files, string output_name) {
		var console = new Console("compile");
		var sorted = new Gee.HashMap<Select.Compiler, Gee.ArrayList<string>>();
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
			entry.value.@foreach((file) => {
				output.add(compile(file, compiler, console));
				return true;
			});
			return true;
		});
		var out_array = output.to_array();
		var vala_files = new Gee.HashMap<int, string>();
		for(int i = 0; i < out_array.length; i++) {
			var parts = out_array[i].split(".");
			if(parts[1] == "c") { // Compiled to C
				console.log("Vala file: " + out_array[i]);
				vala_files.@set(i, out_array[i]);
			}
		}
		vala_files.@foreach((entry) => {
			compile(entry.value, new Select.Compiler("gcc -c", (f) => ""), console);
			var parts = entry.value.split(".");
			parts[parts.length - 1] = "o";
			output.@set(entry.key, string.joinv(".", parts));
			return true;
		});
		out_array = output.to_array();
		console.log("LD " + string.joinv(" ", out_array) + " -> " + output_name);
		Posix.system("gcc -o " + output_name + " " + string.joinv(" ", out_array));
	}
}
