using Soup;

int main(string[] args) {
    try {
    switch(args[1]) {
        case "init":
            init();
            break;
        case "add":
            addPackage(args[2]);
            break;
        case "remove":
            remove_package(args[2]);
            break;
        case "build":
            buildProject();
            break;
    }
    } catch (Error e) {
        printerr("An error occurred: %s.", e.message);
    } 
    return 0;
}
