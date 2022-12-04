namespace Valapkg.Server.DB {
    Postgres.Database global_db;
    void prepare_queries() {
        global_db.prepare ("get_releases", @"
        SELECT * FROM releases;
        ", null);
    }
}