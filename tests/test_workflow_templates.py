"""Regression tests for Pi workflow prompt-template contracts."""

from __future__ import annotations

import json
import re
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
PROMPTS = REPOSITORY_ROOT / "templates" / "pi" / "prompts"
CHAINS = REPOSITORY_ROOT / "templates" / "pi" / "chains"
HOME_VARIABLES = REPOSITORY_ROOT / "host_vars" / "home" / "vars.yml"
CHAIN_DIR = "<chainDir from Step 0>"


def read_template(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def json_blocks(template: str) -> list[dict]:
    blocks = re.findall(r"```json\n(.*?)\n```", template, flags=re.DOTALL)
    return [json.loads(block) for block in blocks]


def agent_tasks(payload: dict) -> list[dict]:
    if "tasks" in payload:
        return payload["tasks"]
    if "agent" in payload:
        return [payload]
    return []


class WorkflowTemplateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.plan_prompt = read_template(PROMPTS / "plan.md")
        cls.implement_prompt = read_template(PROMPTS / "implement.md")
        cls.plan_chain = read_template(CHAINS / "plan.chain.md")
        cls.implement_chain = read_template(CHAINS / "implement.chain.md")
        cls.all_templates = "\n".join(
            [
                cls.plan_prompt,
                cls.implement_prompt,
                cls.plan_chain,
                cls.implement_chain,
            ]
        )

    def test_prompts_use_and_create_local_chain_directory(self) -> None:
        expected = 'chainDir="$(pwd)/tmp/agents_chain/<slug>"'
        for template in (self.plan_prompt, self.implement_prompt):
            self.assertIn(expected, template)
            self.assertIn('mkdir -p "$chainDir"', template)

    def test_no_legacy_session_directory_remains(self) -> None:
        self.assertNotIn("$HOME/.pi/agent/sessions/", self.all_templates)

    def test_prompt_json_examples_are_valid(self) -> None:
        self.assertGreater(len(json_blocks(self.plan_prompt)), 0)
        self.assertGreater(len(json_blocks(self.implement_prompt)), 0)

    def test_agent_payloads_include_chain_directory_and_output(self) -> None:
        for template in (self.plan_prompt, self.implement_prompt):
            for payload in json_blocks(template):
                for task in agent_tasks(payload):
                    self.assertEqual(CHAIN_DIR, task["chainDir"])
                    self.assertTrue(task["output"].startswith(f"{CHAIN_DIR}/"))

    def test_outputs_are_descendants_of_chain_directory(self) -> None:
        for template in (self.plan_prompt, self.implement_prompt):
            for payload in json_blocks(template):
                for task in agent_tasks(payload):
                    self.assertRegex(task["output"], rf"^{re.escape(CHAIN_DIR)}/[^/]+\.md$")

    def test_coderabbit_is_work_only_and_home_uses_sol_high_reviewer(self) -> None:
        self.assertIn("{% if inventory_hostname == 'work' %}", self.implement_prompt)
        self.assertIn("Do not invoke CodeRabbit on home hosts.", self.implement_prompt)
        self.assertIn('model: "openai-codex/gpt-5.6-sol"', read_template(HOME_VARIABLES))
        self.assertIn('thinking: "high"', read_template(HOME_VARIABLES))

    def test_web_research_requires_tools_and_has_a_diagnostic_fallback(self) -> None:
        self.assertIn("web_search", self.plan_prompt)
        self.assertIn("fetch_content", self.plan_prompt)
        self.assertIn("run a `delegate` task", self.plan_prompt)
        self.assertIn("Status: UNAVAILABLE", self.plan_prompt)
        self.assertIn("Required web-search or content-fetch capability is unavailable.", self.plan_prompt)

    def test_research_retries_missing_artifacts_before_stopping(self) -> None:
        self.assertIn("Retry each missing task once.", self.plan_prompt)
        self.assertIn("do not invoke the plan chain", self.plan_prompt)
        self.assertIn("Preserve successful artifacts", self.plan_prompt)

    def test_plan_chain_uses_only_chain_dir_paths(self) -> None:
        self.assertIn("{chain_dir}", self.plan_chain)
        self.assertIn("{chain_dir}", self.implement_chain)
        self.assertNotIn(".pi/agent/sessions", self.plan_chain)
        self.assertNotIn(".pi/agent/sessions", self.implement_chain)


if __name__ == "__main__":
    unittest.main()
