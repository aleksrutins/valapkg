using Valapkg.Server.DB;

namespace Valapkg.Server.API {
    class Release {
        string owner;
        string package;
        string version;
        string text;
        public Release.from_pg(Postgres.Result res, int row_num) {
            owner =   res.get_value(row_num, 0);
            package = res.get_value(row_num, 1);
            version = res.get_value(row_num, 2);
            text =    res.get_value(row_num, 3);
        }
    }

    List<Release> all_releases() {
        var releases = new List<Release>();
        var result = global_db.exec_prepared("get_releases", 0, null, null, null, 0);
        var length = result.get_n_tuples();
        for(var row = 0; row < length; row++) {
            releases.append(new Release.from_pg(result, row));
        }
        return releases;
    }
}