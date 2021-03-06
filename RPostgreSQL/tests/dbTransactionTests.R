## Transaction test using two connections
##
## Assumes that
##  a) PostgreSQL is running, and
##  b) the current user can connect
## both of which are not viable for release but suitable while we test
##
## Dirk Eddelbuettel, 10 Sep 2009

## only run this if this env.var is set correctly
if (Sys.getenv("POSTGRES_USER") != "" & Sys.getenv("POSTGRES_HOST") != "" & Sys.getenv("POSTGRES_DATABASE") != "") {

    ## try to load our module and abort if this fails
    stopifnot(require(RPostgreSQL))
    stopifnot(require(datasets))

    ## load the PostgresSQL driver
    drv <- dbDriver("PostgreSQL")

    ## create two independent connections
    con1 <- dbConnect(drv,
                     user=Sys.getenv("POSTGRES_USER"),
                     password=Sys.getenv("POSTGRES_PASSWD"),
                     host=Sys.getenv("POSTGRES_HOST"),
                     dbname=Sys.getenv("POSTGRES_DATABASE"),
                     port=ifelse((p<-Sys.getenv("POSTGRES_PORT"))!="", p, 5432))

    con2 <- dbConnect(drv,
                     user=Sys.getenv("POSTGRES_USER"),
                     password=Sys.getenv("POSTGRES_PASSWD"),
                     host=Sys.getenv("POSTGRES_HOST"),
                     dbname=Sys.getenv("POSTGRES_DATABASE"),
                     port=ifelse((p<-Sys.getenv("POSTGRES_PORT"))!="", p, 5432))


    if (dbExistsTable(con1, "rockdata")) {
        cat("Removing rockdata\n")
        dbRemoveTable(con1, "rockdata")
    }

    cat("begin transaction in con1\n")
    dbGetQuery(con1, "BEGIN TRANSACTION")
    cat("create table rockdata in con1\n")
    dbWriteTable(con1, "rockdata", rock)
    if (dbExistsTable(con1, "rockdata")) {
        cat("PASS rockdata is visible through con1\n")
    }else{
        cat("FAIL rockdata is invisible through con1\n")
    }
    if (dbExistsTable(con2, "rockdata")) {
        cat("FAIL rockdata is visible through con2\n")
    }else{
        cat("PASS rockdata is invisible through con2\n")
    }
    cat("commit in con1\n")
    dbCommit(con1)
    if (dbExistsTable(con2, "rockdata")) {
        cat("PASS rockdata is visible through con2\n")
    }else{
        cat("FAIL rockdata is invisible through con2\n")
    }

    cat("remove the table from con1\n")
    dbRemoveTable(con1, "rockdata")

    if (dbExistsTable(con2, "rockdata")) {
        cat("FAIL rockdata is visible through con2\n")
    }else{
        cat("PASS rockdata is invisible through con2\n")
    }

    cat("begin transaction in con1\n")
    dbGetQuery(con1, "BEGIN TRANSACTION")
    cat("create table rockdata in con1\n")
    dbWriteTable(con1, "rockdata", rock)
    if (dbExistsTable(con1, "rockdata")) {
        cat("PASS rockdata is visible through con1\n")
    }else{
        cat("FAIL rockdata is invisible through con1\n")
    }
    cat("RollBack con1\n")
    dbRollback(con1)
    if (dbExistsTable(con1, "rockdata")) {
        cat("FAIL rockdata is visible through con1\n")
    }else{
        cat("PASS rockdata is invisible through con1\n")
    }

    ## and disconnect
    dbDisconnect(con2)
    dbDisconnect(con1)
}else{
    cat("Skip.\n")
}
