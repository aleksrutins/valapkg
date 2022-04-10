using ValaConsole;
public void remove_package(string pkg_name) {
    var sp = Spinner.createAndStart("Removing...", "Removed.");
    var console = new Console("remove");
    try {
        Util.spawn_stdout_v("git", "rm", "-f", @"modules/$pkg_name");
        Util.spawn_stdout_v("rm", "-rf", @".git/modules/modules/$pkg_name");
        Util.spawn_stdout_v("git", "submodule", "deinit", "-f", @"modules/$pkg_name");
    } catch(Error e) {
        console.error(@"An error occurred: $(e.message).");
    }
    sp.stop("Removed.");
}