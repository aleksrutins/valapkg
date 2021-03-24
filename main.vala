using Soup;

int main(string[] args) {
    switch(args[1]) {
        case "init":
            init();
            break;
        case "add":
            addPackage(args[2]);
            break;
        case "remove":
            remove(args[2]);
            break;
        case "build":
            buildProject();
            break;
    }
    return 0;
}
