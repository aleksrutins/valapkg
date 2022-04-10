namespace Valabuild {
	public class Select {
		public delegate string CompilerOutput(string filename, string output_directory);
		public delegate string CompilerCommand(string filename, string output_directory, string outNames, string flags);
		public class Compiler {
			public CompilerCommand cmd;
			public unowned CompilerOutput outRule;
			public bool isVala;
			public Compiler(CompilerCommand cmd, CompilerOutput outRule, bool isVala) {
				this.cmd = cmd;
				this.outRule = outRule;
				this.isVala = isVala;
			}
		}
		public static Compiler compiler(string filename) {
			var parts = filename.split(".");
			switch(parts[parts.length - 1]) {
				case "vala":
				case "vapi":
				case "gs":
					return new Compiler((name, output, outNames, flags) => {
						return @"valac $flags -C $name -d $output";
					}, (name, output) => {
						string[] names = name.split(" ");
						Gee.ArrayList<string> outNames = new Gee.ArrayList<string>();
						foreach(var name1 in names) {
							string[] inName = name1.split(".");
							var outName = new Gee.ArrayList<string>();
							foreach(var part in inName[0:(inName.length - 1)]) {
								outName.add(part);
							}
							outName.add("c");
							outNames.add(output + "/" + string.joinv(".", outName.to_array()));
						}
						return string.joinv(" ", outNames.to_array());
					}, true);
				case "c":
				case "cpp":
				case "cxx":
				case "cc":
				case "m":
				case "mm":
				case "mpp":
				return new Compiler((name, output, outNames, flags) => {
					return @"gcc $flags -c $name -o $outNames";
				}, (name, output) => {
					string[] names = name.split(" ");
					Gee.ArrayList<string> outNames = new Gee.ArrayList<string>();
					foreach(var name1 in names) {
						string[] inName = name1.split(".");
						var outName = new Gee.ArrayList<string>();
						if(inName[0].has_prefix(output + "/")) {
							inName[0] = inName[0].substring((output + "/").length);
						}
						foreach(var part in inName[0:(inName.length - 1)]) {
							outName.add(part);
						}
						outName.add("o");
						outNames.add(output + "/" + string.joinv(".", outName.to_array()));
					}
					return string.joinv(" ", outNames.to_array());
				}, false);
				default:
					return new Compiler(() => "echo Could not find compiler for", (name) => "", false);
			}
		}
	}
}
