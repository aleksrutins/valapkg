namespace Util {
    public string spawn_stdout(string cmd) throws Error {
        string[] spawn_args = cmd.split(" ");
		return spawn_stdout_args(spawn_args);
    }
    public string spawn_stdout_v(string argv0, ...) throws Error {
        var varargs_list = va_list();
        string[] args = {argv0};
        for (string arg = varargs_list.arg(); arg != null; arg = varargs_list.arg()) {
            args += arg;
        }
        return spawn_stdout_args(args);
    }
    public string spawn_stdout_args(string[] args) throws Error {
        string[] spawn_env = Environ.get ();
		string ls_stdout;
		string ls_stderr;
		int ls_status;

		Process.spawn_sync (null,
                            args,
							spawn_env,
							SpawnFlags.SEARCH_PATH,
							null,
							out ls_stdout,
							out ls_stderr,
							out ls_status);
        return ls_stdout;
    }
}