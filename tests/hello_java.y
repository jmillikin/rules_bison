%language "Java"
%name-prefix "HelloJava"
%define parser_class_name { HelloJavaParser }
%define public

%start greeting
%token HELLO WORLD

%%

greeting: HELLO WORLD {
    System.out.println("Hello, world!");
}
