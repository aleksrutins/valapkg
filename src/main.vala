using Valapkg.Internal;

namespace Valapkg {
    void main(string[] args) {
        try {
            switch (args[0]) {
            case "init":
                var cwd = getcwd();
                var cwd_parts = cwd.split("/");
                var dirname = cwd_parts[cwd_parts.length];
                File.new_for_path("project.json").create(FileCreateFlags.NONE).write((uint8[]) (@"
        {
            \"name\": \"$(dirname)\",
            \"dependencies\": {},
            \"devDependencies\": {},

        }
                "));
                break;
            }
        } catch(Error e) {}
    }
}
