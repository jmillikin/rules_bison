class HelloJavaLexer implements HelloJavaParser.Lexer {
    int next_token = 0;

    public void yyerror (String s) {
        System.err.println(s);
    }

    public Object getLVal() {
      return null;
    }

    public int yylex () throws java.io.IOException {
        switch (next_token++) {
        case 0:
            return HELLO;
        case 1:
            return WORLD;
        default:
            return EOF;
        }
    }
}

public class HelloJavaMain {
    public static void main (String args[]) throws java.io.IOException {
        HelloJavaParser.Lexer l = new HelloJavaLexer();
        HelloJavaParser p = new HelloJavaParser(l);
        p.parse();
    }
}
