/*
 * Copyright 2018 the rules_bison authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
**/

#include <cstdio>
#include <cstring>

static const char* B4_CAT_START = "cat <<'_m4eof'\n";
static const char* B4_CAT_END = "_m4eof\n";

static bool is_b4_cat(int argc, char **argv, char **message) {
    static const size_t B4_CAT_START_LEN = strlen(B4_CAT_START);
    static const size_t B4_CAT_END_LEN = strlen(B4_CAT_END);

    if (argc != 3) {
        return false;
    }
    if (strcmp(argv[0], "sh") != 0) {
        return false;
    }
    if (strcmp(argv[1], "-c") != 0) {
        return false;
    }
    if (strncmp(argv[2], B4_CAT_START, B4_CAT_START_LEN) != 0) {
        return false;
    }

    *message = argv[2] + B4_CAT_START_LEN;

    size_t message_len = strlen(*message);
    if (message_len <= B4_CAT_END_LEN) {
        return false;
    }
    message_len -= B4_CAT_END_LEN;
    if (strcmp((*message) + message_len, B4_CAT_END) != 0) {
        return false;
    }
    (*message)[message_len] = 0;
    return true;
}

int main(int argc, char **argv) {
    /*
    Recognize the specific case of b4_cat(), used for debug logging. If this
    looks like a call to b4_cat() then extract the message and forward it
    to stderr, where Bazel can see it.
    */
    char *message = NULL;
    if (!is_b4_cat(argc, argv, &message)) {
        fprintf(stderr, "rules_bison forbids shell execution by default\n");
        return 1;
    }
    fputs(message, stderr);
    return 0;
}
