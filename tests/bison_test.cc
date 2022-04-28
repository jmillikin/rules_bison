#include <fstream>
#include <iostream>

#include "gmock/gmock.h"
#include "gtest/gtest.h"
#include "tools/cpp/runfiles/runfiles.h"

using bazel::tools::cpp::runfiles::Runfiles;
using std::string;
using testing::HasSubstr;

#ifdef _WIN32
# define EXE ".exe"
#else
# define EXE ""
#endif

class RulesBison : public ::testing::Test {
  protected:
    void SetUp() override {
        string error;
        runfiles_.reset(Runfiles::CreateForTest(&error));
        ASSERT_EQ(error, "");
    }

    string ReadFile(const string& path) {
        string resolved_path = runfiles_->Rlocation(path);
        std::ifstream fp(resolved_path, std::ios_base::binary);
        EXPECT_TRUE(fp.is_open());
        std::stringstream buf;
        buf << fp.rdbuf();
        return buf.str();
    }

    string TestsDir() {
        const char *test_binary_ptr = getenv("TEST_BINARY");
        const char *test_workspace_ptr = getenv("TEST_WORKSPACE");

        if (test_binary_ptr == nullptr) {
            EXPECT_NE(test_binary_ptr, nullptr);
            return "";
        }
        if (test_workspace_ptr == nullptr) {
            EXPECT_NE(test_workspace_ptr, nullptr);
            return "";
        }

        string test_binary(test_binary_ptr);
        string test_workspace(test_workspace_ptr);

        size_t slash = test_binary.find_last_of('/');
        if (slash == string::npos) {
            EXPECT_NE(slash, string::npos);
            return "";
        }

        return test_workspace + "/" + test_binary.substr(0, slash);
    }

    std::unique_ptr<Runfiles> runfiles_;
};

TEST_F(RulesBison, GenruleTest) {
    const auto parser_src = ReadFile(TestsDir() + "/genrule_output.c");
    ASSERT_THAT(parser_src, HasSubstr("Bison implementation for Yacc-like parsers in C"));
}

TEST_F(RulesBison, CompiledParserC) {
    const auto hello_c_bin = ReadFile(TestsDir() + "/hello_c_bin" EXE);
    ASSERT_TRUE(hello_c_bin.size() > 0);
}

TEST_F(RulesBison, CompiledParserCxx) {
    const auto hello_cc_bin = ReadFile(TestsDir() + "/hello_cc_bin" EXE);
    ASSERT_TRUE(hello_cc_bin.size() > 0);
}

TEST_F(RulesBison, CompiledParserJava) {
    const auto hello_java_bin = ReadFile(TestsDir() + "/HelloJavaMain.jar");
    ASSERT_TRUE(hello_java_bin.size() > 0);

}
