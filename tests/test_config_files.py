"""Regression tests for the cp role's file manifest and the Pi agent templates.

Two classes of bug this guards against, both of which shipped and were only
caught by hand:

1. A `config_files` entry pointing at a `src:` that no longer exists (or that
   git does not track), which fails the play on the target host rather than in
   review.
2. An agent `.md` whose frontmatter is not valid YAML. Pi skips such a file with
   a warning, so the agent silently does not exist — an unquoted description
   containing ": " did exactly that.
"""

from __future__ import annotations

import re
import subprocess
import unittest
from pathlib import Path

try:
    import yaml
except ImportError:  # pyyaml is not guaranteed outside the Ansible venv
    yaml = None

REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
GROUP_VARS = REPOSITORY_ROOT / "group_vars" / "all.yml"
AGENTS_DIR = REPOSITORY_ROOT / "templates" / "pi" / "agents"
SUBAGENTS_JSON = REPOSITORY_ROOT / "templates" / "pi" / "subagents.json"

# `src: "./templates/..."`, as written in the config_files list.
SRC_PATTERN = re.compile(r'^\s*src:\s*"(?P<path>[^"]+)"', re.MULTILINE)
DEST_PATTERN = re.compile(r'^\s*dest:\s*"(?P<path>[^"]+)"', re.MULTILINE)
FENCE = re.compile(r"^---[ \t]*$")


def tracked_files() -> set[str]:
    out = subprocess.run(
        ["git", "-C", str(REPOSITORY_ROOT), "ls-files"],
        capture_output=True,
        text=True,
        check=True,
    )
    return set(out.stdout.split())


def frontmatter(text: str) -> str:
    """The frontmatter block, or "" when the file has none.

    Mirrors Pi's own scan: the block opens on the first line and closes on the
    next line that is exactly `---`.
    """
    lines = text.lstrip("\ufeff").splitlines()
    if not lines or not FENCE.match(lines[0]):
        return ""
    for index, line in enumerate(lines[1:], start=1):
        if FENCE.match(line):
            return "\n".join(lines[1:index])
    return ""


class ConfigFilesTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.group_vars = GROUP_VARS.read_text(encoding="utf-8")
        cls.tracked = tracked_files()

    def test_every_src_exists(self) -> None:
        for match in SRC_PATTERN.finditer(self.group_vars):
            relative = match.group("path").removeprefix("./")
            with self.subTest(src=relative):
                self.assertTrue(
                    (REPOSITORY_ROOT / relative).exists(),
                    f"config_files references {relative}, which does not exist",
                )

    def test_every_src_is_tracked(self) -> None:
        for match in SRC_PATTERN.finditer(self.group_vars):
            relative = match.group("path").removeprefix("./")
            path = REPOSITORY_ROOT / relative
            if path.is_dir():
                continue
            with self.subTest(src=relative):
                self.assertIn(
                    relative,
                    self.tracked,
                    f"{relative} is deployed but not tracked by git "
                    "(check .gitignore for a missing un-ignore)",
                )

    def test_no_duplicate_destinations(self) -> None:
        destinations = [m.group("path") for m in DEST_PATTERN.finditer(self.group_vars)]
        duplicates = {d for d in destinations if destinations.count(d) > 1}
        self.assertEqual(set(), duplicates, f"duplicate config_files dest: {duplicates}")


class AgentTemplateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.agent_files = sorted(AGENTS_DIR.glob("*.md"))
        cls.group_vars = GROUP_VARS.read_text(encoding="utf-8")

    def test_agents_exist(self) -> None:
        self.assertTrue(self.agent_files, "no agent templates found")

    @unittest.skipIf(yaml is None, "pyyaml not installed")
    def test_frontmatter_parses(self) -> None:
        for path in self.agent_files:
            with self.subTest(agent=path.name):
                block = frontmatter(path.read_text(encoding="utf-8"))
                self.assertNotEqual("", block, f"{path.name} has no frontmatter block")
                try:
                    parsed = yaml.safe_load(block)
                except yaml.YAMLError as err:  # pragma: no cover - failure path
                    self.fail(f"{path.name} frontmatter is not valid YAML: {err}")
                self.assertIsInstance(
                    parsed, dict, f"{path.name} frontmatter is not a mapping"
                )

    def test_every_agent_is_deployed(self) -> None:
        for path in self.agent_files:
            relative = path.relative_to(REPOSITORY_ROOT).as_posix()
            with self.subTest(agent=path.name):
                self.assertIn(
                    relative,
                    self.group_vars,
                    f"{relative} has no config_files entry, so it is never deployed",
                )

    def test_no_builtin_shadow_stubs(self) -> None:
        """subagents.json suppresses the built-ins, so shadow stubs are dead weight."""
        for name in ("Explore.md", "Plan.md", "general-purpose.md"):
            with self.subTest(agent=name):
                self.assertFalse(
                    (AGENTS_DIR / name).exists(),
                    f"{name} shadows a built-in that disableDefaultAgents already removes",
                )


if __name__ == "__main__":
    unittest.main()
