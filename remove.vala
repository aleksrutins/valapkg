using ValaConsole;
public void remove(string pkg_name) {
    var sp = Spinner.createAndStart("Removing...");
    Util.spawn_stdout_v("git", "rm", "-f", @"modules/$pkg_name");
    Util.spawn_stdout_v("rm", "-rf", @".git/modules/modules/$pkg_name");
    Util.spawn_stdout_v("git", "submodule", "deinit", "-f", @"modules/$pkg_name");
    sp.stop("Removed.");
}