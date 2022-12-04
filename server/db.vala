namespace Valapkg.Server.DB {
    Postgres.Database global_db;
    void prepare_queries() {
        global_db.prepare ("get_releases", @"
        SELECT * FROM releases;
        ", null);
        global_db.prepare("get_dependencies", "
        SELECT 
            to_owner as owner,
            to_package as package,
            to_version as version
        FROM dependencies
            WHERE from_owner = $1
            AND from_package = $2
            AND from_version = $3;
        ", null);
    }
}