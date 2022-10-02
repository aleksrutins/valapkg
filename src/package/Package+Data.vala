using Gee;

public class Valapkg.DependencyResolver {
    public string desc;

    public DependencyResolver.compile(string desc) {
        this.desc = desc;
        var regex = new Regex ("", RegexCompileFlags.JAVASCRIPT_COMPAT);
    }
}

public partial class Valapkg.Package : Object {
    public string name;
    public HashMap<string, DependencyResolver> dependencies;
    public HashMap<string, DependencyResolver> dev_dependencies;
}
