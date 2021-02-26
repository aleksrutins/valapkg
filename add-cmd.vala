void addPackage(string name) {
    var console = new Console("add");
    var curPkg = Package.get_current();
    console.log("Adding to dependencies");
    curPkg.get_object().get_array_member("dependencies").add_string_element(name);
    try {
        Package.write(curPkg);
    } catch(Error e) {
        console.error(e.message);
        return;
    }
    console.log("Installing")
    Package.install(name);
}