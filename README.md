# Frontend Shift-Left Audit

**Audit your frontend project's code quality, testing, and CI/CD setup in one command.**

A free, open-source [Claude Code skill](https://docs.anthropic.com/en/docs/claude-code/skills) that analyzes JavaScript and TypeScript repositories for gaps in linting (ESLint, Biome), type safety, testing (Jest, Vitest, Playwright, Cypress), security scanning, accessibility checks, and CI/CD pipelines. Works with React, Vue, Angular, Svelte, Next.js, Nuxt, Remix, Astro, and more.

## Why this skill

- **Goes beyond `devDependencies`.** Most audit tools check if a package is installed. This one verifies tools are actually configured and enforced in CI - not just sitting unused in your lockfile.
- **Rendering-strategy-aware.** Security and testing recommendations differ for SSR, CSR, SSG, and hybrid apps. An `eslint-plugin-security` recommendation that makes sense for a Next.js SSR app is misleading for a Vite CSR SPA.
- **Scored report.** Each of 13 categories gets a rating (strong / adequate / weak / missing) and the project gets an overall A-F grade with a prioritized fix list.

## Installation

Clone the repo into your Claude Code skills directory:

```bash
git clone https://github.com/SBub/frontend-shift-left-audit ~/.claude/skills/frontend-shift-left-audit
```

After installation, `/frontend-shift-left-audit` will be available as a slash command in Claude Code.

> **Note:** Only `SKILL.md` and `reference.md` are used at runtime. The other files (README, LICENSE, CONTRIBUTING, tests/) are for contributors and won't affect the skill.

## Usage

```
/frontend-shift-left-audit [path-to-repo]
```

If no path is provided, it audits the current working directory.

## Example output

```
=== FRONTEND SHIFT-LEFT AUDIT ===
Framework: Next.js 14
Rendering: SSR (App Router)
Language: TypeScript
Monorepo: No

| Category             | Status   | Details                                          |
|----------------------|----------|--------------------------------------------------|
| Code Linting         | strong   | ESLint + next/core-web-vitals + security + a11y   |
| Type Safety          | strong   | TypeScript strict mode enabled                    |
| Code Formatting      | strong   | Prettier configured, format:check in CI           |
| Security Scanning    | strong   | eslint-plugin-security (SSR), no-secrets, npm audit in CI |
| Accessibility        | strong   | jsx-a11y + axe-core in Playwright e2e             |
| Dead Code Detection  | strong   | Knip configured + tree shaking via Next.js        |
| Circular Imports     | adequate | import/no-cycle in ESLint, not enforced in CI     |
| Unit Testing         | strong   | Vitest + @testing-library/react, 80% coverage threshold |
| Integration Testing  | missing  | MSW installed but no browser-based integration tests |
| E2E Testing          | strong   | Playwright with webServer config, runs in CI      |
| Visual Regression    | missing  | No Chromatic, Percy, or Storybook detected        |
| Coverage             | strong   | v8 provider, thresholds set, reported in CI       |
| CI/CD Integration    | strong   | GitHub Actions: type-check, lint, format, test, e2e, security |

Overall Grade: A (34/39)
```

The full report also includes **Critical Gaps**, **Framework-Specific Recommendations**, **Quick Wins**, and optional **Hardening Suggestions**.

## What it audits

| Category | What it checks |
|----------|---------------|
| **Static analysis** | Linting, type safety, formatting, security scanning, accessibility, dead code detection, circular imports, bundle analysis |
| **Testing** | Unit, integration, e2e, visual regression, coverage, SSR-specific |
| **CI/CD** | Pipeline coverage, which checks run in CI, branch protection |

Detection covers tools like **ESLint**, **Biome**, **Oxlint**, **Prettier**, **TypeScript**, **Jest**, **Vitest**, **Playwright**, **Cypress**, **Storybook**, **Chromatic**, **Percy**, **axe-core**, **eslint-plugin-security**, **Knip**, **dependency-cruiser**, **npm audit**, **Snyk**, **GitHub Actions**, **GitLab CI**, **CircleCI**, and **Jenkins**.

## How is this different from SonarQube / CodeClimate?

| | This skill | SonarQube / CodeClimate / Codacy |
|---|---|---|
| **Focus** | Frontend-specific - framework-aware, rendering-strategy-aware (SSR/CSR/SSG) | Language-agnostic, backend-oriented |
| **What it checks** | Infrastructure: are tools installed, configured, *and enforced*? | Source code: bugs, code smells, duplication |
| **CI/CD awareness** | Audits your pipeline config (GitHub Actions, GitLab CI, Jenkins) | Runs *inside* your pipeline |
| **Setup** | Zero config - one command, read-only | Requires server/SaaS setup, dashboard, tokens |
| **Cost** | Free, open source | Free tiers; full features are paid |

They're complementary: use SonarQube or CodeClimate to scan your *code*, use this skill to audit whether your *tooling and processes* are set up correctly.

## Supported frameworks

**Next.js**, **Nuxt**, **Remix**, **Gatsby**, **Angular**, **SvelteKit**, **Astro**, **Vite**, **CRA**, and any other frontend setup with a `package.json` - whether written in **JavaScript** or **TypeScript**.

## Who is this for

- You just inherited a frontend codebase and need to assess its quality infrastructure.
- You're setting up a new project and want a checklist of what to configure.
- You're a tech lead doing a cross-team audit of engineering practices.
- You want a baseline audit before a refactor or migration.

## Why "shift left"?

"Shift left" means moving quality checks **earlier** in the development lifecycle - catching issues at the linting/testing/CI stage instead of in QA, staging, or production.

```
Code written → Linting → Type check → Tests → CI → Review → Deploy → Production
              ←------------- shift left --------------→
              catch it here,                          not here
```

This skill evaluates how far left your frontend project has shifted its bug detection.

## Testing

The skill is tested against 10 synthetic mock repos (Next.js, Nuxt, Vite, Angular, SvelteKit, Remix, Gatsby, monorepo, empty repo) with known tool configurations, so detection accuracy can be verified against expected results.

Four agent personas evaluate each audit from different angles:

| Persona | Focus |
|---------|-------|
| **DevOps Engineer** | CI/CD platform detection, pipeline step accuracy |
| **Frontend DevOps Engineer** | Tooling detection, ESLint config parsing, installed vs configured |
| **Frontend Developer** | Report clarity, scoring fairness, actionability of recommendations |
| **Skill Author** | Output consistency, edge cases, hallucination prevention |

To run tests:

```bash
# Generate mock repos
bash tests/generate-mocks.sh

# Audit a mock repo
/frontend-shift-left-audit /tmp/shift-left-audit-test-repos/02-nextjs-full

# Evaluate with agent personas (see tests/ for prompts)
```

See `tests/TEST_PLAN.md` for the full test strategy and `tests/run-tests.md` for expected results per repo.

## Key design decisions

- **"Installed" ≠ "configured" ≠ "enforced."** The skill verifies that tools are actually configured and running, not just present in `devDependencies`.
- **Rendering-strategy-aware.** Security, testing, and SSR-specific recommendations adapt based on whether the app is CSR, SSR, SSG, or hybrid.
- **Tree shaking vs source-level dead code.** These are distinct layers - the skill evaluates both separately.
- **Read-only.** The skill never modifies files. It only reads and reports.

## Contributing

Found a gap in detection? [Open an issue](https://github.com/SBub/frontend-shift-left-audit/issues). Want to add support for a framework or tool? See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

MIT
