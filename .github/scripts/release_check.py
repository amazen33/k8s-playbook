#!/usr/bin/env python3
"""Release-stream checks (Dev -> Candidate -> Stable). See RELEASING.md.

  check      pull requests and pushes: version source and changelog rules
  tag TAG    release workflow: tag, version, changelog and branch rules

Standard library only.
"""
import argparse
import os
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

BASE = re.compile(r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
TAG = re.compile(r"^v((?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*))(?:-(alpha|beta|rc)\.([1-9]\d*))?$")
ROOT = Path.cwd()


def fail(message):
    print(f"::error::{message}")
    sys.exit(1)


def git(*args):
    return subprocess.run(["git", *args], capture_output=True, text=True, check=False)


def read_version():
    version_file = ROOT / "VERSION"
    if version_file.is_file():
        return version_file.read_text(encoding="utf-8").strip(), "VERSION"
    pom = ROOT / "pom.xml"
    if pom.is_file():
        root = ET.parse(pom).getroot()
        prefix = root.tag[: root.tag.index("}") + 1] if root.tag.startswith("{") else ""
        element = root.find(f"{prefix}version")
        if element is None or not (element.text or "").strip():
            fail("pom.xml has no project <version>")
        return element.text.strip(), "pom.xml"
    fail("no version source: add VERSION (or pom.xml)")


def base_of(version):
    base = version[: -len("-SNAPSHOT")] if version.endswith("-SNAPSHOT") else version
    if not BASE.match(base):
        fail(f"version '{version}' must be the next release's base X.Y.Z (Maven: X.Y.Z-SNAPSHOT)")
    return base


def changelog():
    path = ROOT / "CHANGELOG.md"
    if not path.is_file():
        fail("CHANGELOG.md is missing")
    return path.read_text(encoding="utf-8")


def section(text, name):
    match = re.search(rf"^## \[{re.escape(name)}\][^\n]*\n(.*?)(?=^## \[|\Z)", text, re.M | re.S)
    return None if match is None else match.group(1).strip()


def tag_exists(name):
    return git("rev-parse", "-q", "--verify", f"refs/tags/{name}").returncode == 0


def cmd_check(_args):
    version, source = read_version()
    base = base_of(version)
    if section(changelog(), "Unreleased") is None:
        fail("CHANGELOG.md needs a '## [Unreleased]' section")
    if tag_exists(f"v{base}"):
        fail(f"{source} says {base}, which is already released as v{base}; bump it to the next version")
    if os.environ.get("EVENT") == "pull_request":
        changed = git("diff", "--name-only", f"{os.environ.get('BASE_SHA', '')}...HEAD").stdout.split()
        if "CHANGELOG.md" not in changed and os.environ.get("SKIP_CHANGELOG") != "true":
            fail("update CHANGELOG.md under [Unreleased], or add the 'changelog:skip' label with a reason")
    print(f"ok: {source}={version}; CHANGELOG.md has [Unreleased]")


def cmd_tag(args):
    match = TAG.match(args.tag)
    if not match:
        fail(f"tag '{args.tag}' must be vX.Y.Z or vX.Y.Z-(alpha|beta|rc).N")
    tag_base, pre = match.group(1), match.group(2)
    version, source = read_version()
    if version != tag_base:
        fail(f"tag {args.tag} needs {source} = {tag_base} (found {version})")
    full = args.tag[1:]
    text = changelog()
    notes = section(text, full) or section(text, tag_base)
    if not notes:
        fail(f"CHANGELOG.md needs a non-empty '## [{full}]' or '## [{tag_base}]' section")
    release_branch = "release/" + ".".join(tag_base.split(".")[:2])
    if args.branch == "main":
        allowed = ["main", release_branch]
    elif args.branch == "release":
        allowed = [release_branch]
    else:  # product: alpha/beta from main before the first rc; rc and stable from release/X.Y
        allowed = ["main", release_branch] if pre in ("alpha", "beta") else [release_branch]
    on = [b for b in allowed if git("merge-base", "--is-ancestor", "HEAD", f"origin/{b}").returncode == 0]
    if not on:
        fail(f"the tagged commit is not on {' or '.join(allowed)}")
    where = on[0]
    if pre is None and not git("tag", "--points-at", "HEAD", "--list", f"v{tag_base}-rc.*").stdout.split():
        fail(f"stable {args.tag} must sit on the commit of an accepted v{tag_base}-rc.N candidate")
    if args.notes:
        Path(args.notes).write_text(notes + "\n", encoding="utf-8")
    if args.github_output:
        with open(args.github_output, "a", encoding="utf-8") as handle:
            handle.write(f"prerelease={'true' if pre else 'false'}\n")
    kind = "pre-release" if pre else "stable (draft for the owner to publish)"
    print(f"ok: {args.tag} matches {source}={version}; {kind}; on {where}")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("check").set_defaults(func=cmd_check)
    tag = sub.add_parser("tag")
    tag.add_argument("tag")
    tag.add_argument("--branch", choices=["main", "release", "product"], default="main")
    tag.add_argument("--notes")
    tag.add_argument("--github-output")
    tag.set_defaults(func=cmd_tag)
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
