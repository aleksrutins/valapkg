using GLib;
namespace Valapkg.Build.Glob {
    Gee.ArrayList<File> findFilesRecursively(File directory, string[] extensions) throws Error {
        var files = directory.enumerate_children("standard::*", FileQueryInfoFlags.NONE);
        var result = new Gee.ArrayList<File>();
        FileInfo info;
        while((info = files.next_file()) != null) {
            var file = directory.resolve_relative_path(info.get_name());
            if(info.get_file_type() == FileType.DIRECTORY) {
                result.add_all(findFilesRecursively(file, extensions));
            } else {
                result.add(file);
            }
        }
        return result;
    }
}