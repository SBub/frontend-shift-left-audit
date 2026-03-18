# Contributing

## How the skill works

The skill is a Claude Code prompt (`SKILL.md`) with a reference file (`reference.md`) containing detection patterns and lookup tables. When invoked, Claude reads the target repo's files and produces a structured audit report.

There is no runtime code - the "logic" is in the prompt instructions.

## Adding a new detection rule

1. **Add the check to `SKILL.md`** in the appropriate section (2.x for static analysis, 3.x for testing, 4.x for CI/CD)
2. **Add detection patterns to `reference.md`** - config file names, package names, CLI flags to look for
3. **Update mock repos** - edit `tests/generate-mocks.sh` to add the tool to at least one mock repo so detection can be verified
4. **Update expected results** in `tests/run-tests.md` for any affected mock repos

## Adding framework support

1. Add framework detection to Phase 1 in `SKILL.md` (config file name, SSR/CSR indicators)
2. Add a row to the "Framework-Specific SSR Indicators" table in `reference.md`
3. Add a mock repo to `tests/generate-mocks.sh` that uses the framework
4. Add expected results to `tests/run-tests.md`

## Running tests

```bash
# 1. Generate mock repos
bash tests/generate-mocks.sh

# 2. Run the skill against a mock repo
/frontend-shift-left-audit /tmp/shift-left-audit-test-repos/01-nextjs-bare

# 3. Evaluate with agent personas (see tests/ directory for evaluation prompts)
```

The test suite uses 4 agent personas that evaluate the audit from different perspectives:
- **DevOps Engineer** - CI/CD detection accuracy
- **Frontend DevOps Engineer** - tooling detection accuracy
- **Frontend Developer** - report actionability and clarity
- **Skill Author** - structural robustness and consistency

See `tests/TEST_PLAN.md` for full details.

## Key principles

- **Factual only.** The skill must never hallucinate tools that aren't in the repo. Every detection must trace back to a file or config.
- **"Installed" ≠ "configured" ≠ "enforced."** Always verify tools are actually set up, not just in `devDependencies`.
- **Rendering-strategy-aware.** Recommendations must account for SSR vs CSR vs SSG.
- **Read-only.** The skill never modifies files in the target repo.
- **Actionable.** Every recommendation includes a concrete command or config snippet.
