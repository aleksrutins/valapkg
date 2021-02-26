void addPackage(string name) {
    var console = new Console("add");
    var curPkg = Package.get_current();
    console.log("Adding to dependencies");
    var nodeDepName = new Json.Node.alloc();
    nodeDepName.init_string(name);
    curPkg.get_object().get_array_member("dependencies").add_element(nodeDepName);
    try {
        Package.write(curPkg);
    } catch(Error e) {
        console.error(e.message);
        return;
    }
    console.log("Installing");
    var pkg_name = Package.install(name);
    console.log("Checking for package.json");
    var new_pkgJson = File.new_for_path(@"modules/$pkg_name/package.json");
    if(!new_pkgJson.query_exists()) {
        console.error("package.json not found, removing from dependencies");
        console.error(@"This will not remove the package directory. To remove that, run: rm -rf modules/$pkg_name");
        var deps = curPkg.get_object().get_array_member("dependencies");
        deps.remove_element(deps.get_elements().index(nodeDepName));
        try {
            Package.write(curPkg);
        } catch(Error e) {
            console.error(e.message);
        }
    }
    return;
}