class BuildConf : Object {
	public string[] files;
	public Target[] targets;
}

class Target : Object {
	public string name;
	public string[] files;
}
