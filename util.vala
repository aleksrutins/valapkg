namespace Util {
    public Output spawn_stdout(string cmd) throws Error {
        string[] spawn_args = cmd.split(" ");
		return spawn_stdout_args(spawn_args);
    }
    public Output spawn_stdout_v(string argv0, ...) throws Error {
        var varargs_list = va_list();
        string[] args = {argv0};
        for (string arg = varargs_list.arg(); arg != null; arg = varargs_list.arg()) {
            args += arg;
        }
        return spawn_stdout_args(args);
    }
    public Output spawn_stdout_args(string[] args) throws Error {
        string[] spawn_env = Environ.get ();
		Output output = Output();

		Process.spawn_sync (null,
                            args,
							spawn_env,
							SpawnFlags.SEARCH_PATH,
							null,
							out output.stdout,
							out output.stderr,
							out output.status);
        return output;
    }
    public struct Output {
        string stderr;
        string stdout;
        int status;
    }
}