using Gee;

namespace CompileCommands {
    public class Command : Object {
        public string directory {get; set;}
        public string[] arguments {get; set;}
        public string file {get; set;}
        public string output {get; set;}
    }
    public class Builder {
        private LinkedList<Command?> commands = new LinkedList<Command> ();

        private Json.Node to_node() {
            var node = new Json.Node(ARRAY);
            node.set_array(new Json.Array());
            foreach (var command in commands) {
                node.get_array().add_element(Json.gobject_serialize(command));
            }
            return node;
        }

        public void add(Command cmd) {
            commands.add(cmd);
        }

        public void merge(Builder other) {
            commands.add_all(other.commands);
        }

        public string build() {
            var gen = new Json.Generator();
            gen.set_root(to_node());
            gen.set_pretty(true);
            return gen.to_data(null);
        }
    }
}