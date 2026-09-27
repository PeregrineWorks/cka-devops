"""Turn TODO comments added in a merged pull request into GitHub issues.

Runs from the todo-issues workflow after a pull request merges into dev. It
reads the pull request's diff rather than scanning the whole repository, so only
TODOs that the pull request added become issues. A TODO that already has an open
issue with the same title is skipped, which keeps reruns and repeated merges from
creating duplicates.

A TODO looks like one of these, after '#', '#!' or '//':

    # TODO : Rotate the service account key
    # TODO[research] : Security review - are these best practices?
    #! TODO[feat, networking] : Let nodes talk to each other

The text after the colon becomes the issue title. Each tag in the brackets
becomes a label, next to the 'todo' label every generated issue gets. Comment
lines directly under the TODO become the issue description, up to the first
blank line, line of code, or next TODO:

    # TODO[feat] : Let nodes talk to each other
    # Nodes sit in one subnet but the firewall only allows IAP SSH.
    # Probably needs an internal allow rule on the node tag.
"""

import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass

TODO_LABEL = "todo"
TODO_PATTERN = re.compile(r"(?:#!?|//)\s*TODO(?:\[(?P<tags>[^\]]*)\])?\s*:\s*(?P<text>.+)")
COMMENT_MARKER_PATTERN = re.compile(r"^(?:#!?|//) ?")
DIFF_FILE_PATTERN = re.compile(r"^\+\+\+ b/(?P<path>.+)$")
DIFF_HUNK_PATTERN = re.compile(r"^@@ -\d+(?:,\d+)? \+(?P<start>\d+)(?:,\d+)? @@")
# gh caps list results at 30 unless told otherwise.
GH_LIST_LIMIT = "1000"
# This script's own docstring shows example TODOs, which must not become issues.
IGNORED_PATHS = {".github/scripts/todo_to_issues.py"}


@dataclass(frozen=True)
class NewFileLine:
    path: str
    number: int
    source: str
    is_added: bool


@dataclass(frozen=True)
class Todo:
    path: str
    line: int
    text: str
    tags: list[str]
    description: str


def parse_todos(diff: str) -> list[Todo]:
    """Every TODO on an added line of a unified diff, with the comment lines below it."""
    lines = _new_file_lines(diff)
    todos = []
    for index, line in enumerate(lines):
        if not line.is_added or line.path in IGNORED_PATHS:
            continue
        match = TODO_PATTERN.search(line.source)
        if not match:
            continue
        tags = [tag.strip() for tag in (match["tags"] or "").split(",") if tag.strip()]
        todos.append(
            Todo(
                path=line.path,
                line=line.number,
                text=match["text"].strip(),
                tags=tags,
                description=_description_below(lines, index),
            )
        )
    return todos


def _new_file_lines(diff: str) -> list[NewFileLine]:
    """Added and context lines of a unified diff, numbered as in the new file."""
    lines = []
    path = None
    number = 0
    for diff_line in diff.splitlines():
        file_match = DIFF_FILE_PATTERN.match(diff_line)
        if file_match:
            path = file_match["path"]
            continue
        hunk_match = DIFF_HUNK_PATTERN.match(diff_line)
        if hunk_match:
            number = int(hunk_match["start"])
            continue
        # Removed lines do not exist in the new file, so they do not advance the count.
        if diff_line.startswith("-") or path is None:
            continue
        is_added = diff_line.startswith("+")
        lines.append(NewFileLine(path, number, diff_line[1:], is_added))
        number += 1
    return lines


def _description_below(lines: list[NewFileLine], todo_index: int) -> str:
    """The comment lines directly under a TODO, up to a blank line, code, or the next TODO."""
    description = []
    previous = lines[todo_index]
    for line in lines[todo_index + 1 :]:
        # Hunks skip unchanged stretches, so the next diff line may not be the next file line.
        is_next_line = line.path == previous.path and line.number == previous.number + 1
        source = line.source.strip()
        is_comment = COMMENT_MARKER_PATTERN.match(source) is not None
        if not is_next_line or not is_comment or TODO_PATTERN.search(source):
            break
        # A bare '#' stays in as an empty line, so a description can have paragraphs.
        description.append(COMMENT_MARKER_PATTERN.sub("", source))
        previous = line
    return "\n".join(description).strip()


def issue_body(todo: Todo, branch: str, pr_number: str, permalink: str) -> str:
    """Markdown body. A bare permalink on its own line renders as a code snippet on GitHub."""
    details = (
        f"**Branch:** `{branch}`\n"
        f"**File:** `{todo.path}` (line {todo.line})\n"
        f"**Pull request:** #{pr_number}\n"
        "\n"
        f"{permalink}\n"
    )
    if not todo.description:
        return details
    return f"{todo.description}\n\n---\n\n{details}"


def _gh(*args: str) -> str:
    result = subprocess.run(["gh", *args], check=True, capture_output=True, text=True)
    return result.stdout


def _gh_json_names(*args: str, field: str) -> set[str]:
    items = json.loads(_gh(*args, "--json", field, "--limit", GH_LIST_LIMIT))
    return {item[field] for item in items}


def main() -> None:
    repository = os.environ["GITHUB_REPOSITORY"]
    pr_number = os.environ["PR_NUMBER"]
    branch = os.environ["PR_BRANCH"]
    merge_sha = os.environ["MERGE_SHA"]

    todos = parse_todos(_gh("pr", "diff", pr_number, "--repo", repository))
    if not todos:
        print("No new TODOs in this pull request.")
        return

    open_titles = _gh_json_names(
        "issue", "list", "--repo", repository, "--state", "open", "--label", TODO_LABEL,
        field="title",
    )
    labels = _gh_json_names("label", "list", "--repo", repository, field="name")

    for todo in todos:
        if todo.text in open_titles:
            print(f"Skipping '{todo.text}': an open issue already has this title.")
            continue
        for label in [TODO_LABEL, *todo.tags]:
            if label not in labels:
                _gh("label", "create", label, "--repo", repository)
                labels.add(label)
        permalink = f"https://github.com/{repository}/blob/{merge_sha}/{todo.path}#L{todo.line}"
        label_args = [arg for label in [TODO_LABEL, *todo.tags] for arg in ("--label", label)]
        url = _gh(
            "issue", "create", "--repo", repository,
            "--title", todo.text,
            "--body", issue_body(todo, branch, pr_number, permalink),
            *label_args,
        )
        open_titles.add(todo.text)
        print(f"Created {url.strip()} for {todo.path}:{todo.line}")


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        print(f"gh {' '.join(error.cmd[1:3])} failed:\n{error.stderr}", file=sys.stderr)
        sys.exit(1)
