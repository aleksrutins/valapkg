namespace Valabuild {
	public class Select {
		public static delegate string CompilerOutput(string filename);
		public class Compiler {
			public string cmd;
			public CompilerOutput outRule;
			public Compiler(string cmd, CompilerOutput outRule) {
				this.cmd = cmd;
				this.outRule = outRule;
			}
		}
		public static Compiler compiler(string filename) {
			var parts = filename.split(".");
			switch(parts[parts.length - 1]) {
				case "vala":
				case "vapi":
					return new Compiler("valac -C", (name) => {
						string[] inName = name.split(".");
						var outName = new Gee.ArrayList<string>();
						foreach(var part in inName[0:(inName.length - 1)]) {
							outName.add(part);
						}
						outName.add("c");
						return string.joinv(".", outName.to_array());
					});
				case "c":
				case "cpp":
				case "cxx":
				case "cc":
				case "m":
				case "mm":
				case "mpp":
					return new Compiler("gcc -c", (name) => {
						string[] inName = name.split(".");
						var outName = new Gee.ArrayList<string>();
						foreach(var part in inName[0:(inName.length - 1)]) {
							outName.add(part);
						}
						outName.add("o");
						return string.joinv(".", outName.to_array());
					});
				default:
					return new Compiler("echo Could not find compiler for", (name) => "");
			}
		}
	}
}
