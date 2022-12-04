CREATE TABLE IF NOT EXISTS releases (
    owner varchar(255),
    package varchar(255),
    version varchar(255),
    source text,
    PRIMARY KEY (owner, package, version)
);

CREATE TABLE IF NOT EXISTS dependencies (
    from_owner varchar(255),
    from_package varchar(255),
    from_version varchar(255),
    to_owner varchar(255),
    to_package varchar(255),
    to_version varchar(255),
    CONSTRAINT fk_from
        FOREIGN KEY(from_owner, from_package, from_version)
            REFERENCES releases(owner, package, version)
            ON DELETE CASCADE,
    CONSTRAINT fk_to
        FOREIGN KEY(to_owner, to_package, to_version)
            REFERENCES releases(owner, package, version)
            ON DELETE CASCADE
);