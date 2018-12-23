#include <fstream>
#include <iostream>

#include "gtest/gtest.h"
#include "gmock/gmock.h"

using testing::HasSubstr;

namespace {

std::string ReadFile(const std::string& path) {
    std::ifstream fp(path);
    std::stringstream buf;
    buf << fp.rdbuf();
    return buf.str();
}

}  // namespace

TEST(RulesBison, ParserSkeletonC) {
    const auto parser_hdr = ReadFile("./tests/hello_c.h");
    const auto parser_src = ReadFile("./tests/hello_c.c");

    ASSERT_THAT(parser_hdr, HasSubstr("Bison interface for Yacc-like parsers in C"));
    ASSERT_THAT(parser_src, HasSubstr("Bison implementation for Yacc-like parsers in C"));
}

TEST(RulesBison, ParserSkeletonCxx) {
    const auto parser_hdr = ReadFile("./tests/hello_cc.hh");
    const auto parser_src = ReadFile("./tests/hello_cc.cc");

    ASSERT_THAT(parser_hdr, HasSubstr("Skeleton interface for Bison LALR(1) parsers in C++"));
    ASSERT_THAT(parser_src, HasSubstr("Skeleton implementation for Bison LALR(1) parsers in C++"));
}

TEST(RulesBison, ParserSkeletonJava) {
    const auto parser_src = ReadFile("./tests/hello_java.java");

    ASSERT_THAT(parser_src, HasSubstr("Skeleton implementation for Bison LALR(1) parsers in Java"));
}
