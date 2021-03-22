namespace Util {
    public string spawn_stdout(string cmd) throws Error {
        string[] spawn_args = cmd.split(" ");
		string[] spawn_env = Environ.get ();
		string ls_stdout;
		string ls_stderr;
		int ls_status;

		Process.spawn_sync (null,
                            spawn_args,
							spawn_env,
							SpawnFlags.SEARCH_PATH,
							null,
							out ls_stdout,
							out ls_stderr,
							out ls_status);
        return ls_stdout;
    }
}