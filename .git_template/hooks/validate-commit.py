#!/usr/bin/env python3

# This file is a slightly modified version of
# https://gist.github.com/jasonrobertfox/8057124
import sys
import subprocess

message_file = sys.argv[1]


def check_format_rules(lineno, line):
    if lineno == 0:
        if not line[0].isupper():
            return "ERROR: The first line should be capitalized."
        if len(line) > 50:
            return "ERROR: The first line should be less than 50 characters long"
        if line.endswith("."):
            return "ERROR: The first line should not end with a period"
    if lineno == 1 and line:
        return "ERROR: The second line should be blank"
    if not line.startswith("#") and not line.startswith("diff --git a/") \
            and not line.startswith("+") and not line.startswith("-") \
            and len(line) > 72:
                return "ERROR: Line {} is longer than 72 characters".format(lineno + 1)
    return False


while True:
    commit_msg = []
    errors = []

    with open(message_file) as commit_file:
        for lineno, line in enumerate(commit_file):
            commit_msg.append(line)
            e = check_format_rules(lineno, line.strip())
            if e:
                errors.append(e)

    if errors:
        with open(message_file, 'w') as commit_file:
            commit_file.write("# GIT COMMIT MSG FORMAT ERRORS:\n")
            for error in errors:
                commit_file.write("#    {}\n".format(error))
            for line in commit_msg:
                commit_file.write(line)

        print("Invalid git commit message.")
        confirm_edit = input("Edit message? [yn] > ")
        if confirm_edit.lower() in ['n', 'no']:
            sys.exit(1)
        subprocess.call("vim {}".format(message_file), shell=True)
        continue
    break
