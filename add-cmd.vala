using ValaConsole;
void addPackage(string name) {
    var console = new Console("add");
    console.log("Installing");
    var pkg_name = Package.install(name);
    console.log("Checking for package.json");
    var new_pkgJson = File.new_for_path(@"modules/$pkg_name/package.json");
    if(!new_pkgJson.query_exists()) {
        console.error("package.json not found, removing from dependencies");
        remove_package(pkg_name);
    }
    return;
}