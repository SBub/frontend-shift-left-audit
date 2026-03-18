# Frontend Shift-Left Audit - Test Runner Guide

## Quick Start

### 1. Generate Mock Repos
```bash
bash ~/.claude/skills/frontend-shift-left-audit/tests/generate-mocks.sh
```
This creates 10 mock repos in `/tmp/shift-left-audit-test-repos/`.

### 2. Run the Skill Against a Mock Repo

In Claude Code, run:
```
/frontend-shift-left-audit /tmp/shift-left-audit-test-repos/01-nextjs-bare
```

### 3. Evaluate with Agent Personas

After getting the audit output, run each evaluator by launching agents with the evaluation prompts from:
- `evaluate-devops.md` - CI/CD accuracy
- `evaluate-fe-devops.md` - Tooling detection accuracy
- `evaluate-fe-dev.md` - Report actionability
- `evaluate-skill-author.md` - Skill robustness

Replace the `$VARIABLES` in each prompt with the actual values for the repo being tested.

---

## Expected Results Per Mock Repo

### 01-nextjs-bare
- **Framework**: Next.js 14 | **Rendering**: SSR (App Router)
- **Expected Grade**: D or F
- **Present**: ESLint (basic next config), TypeScript (non-strict), Jest (installed, no tests)
- **Missing**: Security scanning, accessibility, dead code, circular imports, E2E, CI, git hooks, formatting, coverage
- **Key test**: Should NOT falsely claim security or a11y plugins exist

### 02-nextjs-full
- **Framework**: Next.js 14 | **Rendering**: SSR
- **Expected Grade**: A or B
- **Present**: ESLint + security + a11y + no-secrets, TS strict, Vitest + msw + Playwright, Husky + lint-staged, GitHub Actions (full pipeline), knip, Prettier, axe-core, coverage thresholds
- **Missing**: Visual regression testing, circular import tool (but import/no-cycle rule exists)
- **Key test**: Should give high score, recognize import/no-cycle as circular import coverage

### 03-vite-react-csr
- **Framework**: Vite + React | **Rendering**: CSR
- **Expected Grade**: C or D
- **Present**: Biome (linter + formatter), Vitest, TypeScript strict
- **Missing**: CI, security, accessibility, E2E, dead code, circular imports, git hooks
- **Key test**: Must recognize Biome as covering BOTH linting and formatting (not mark either as missing)

### 04-nuxt-ssr
- **Framework**: Nuxt 3 | **Rendering**: SSR
- **Expected Grade**: C
- **Present**: ESLint + vuejs-accessibility, Vitest, Cypress, GitLab CI (lint + test + build), TypeScript
- **Missing**: Security scanning, dead code, circular imports, formatting, git hooks, coverage in CI
- **Key test**: Must detect GitLab CI (not just GitHub Actions). Must detect `ssr: true` in nuxt.config.

### 05-angular-enterprise
- **Framework**: Angular 17 | **Rendering**: SSR (Universal)
- **Expected Grade**: C or D
- **Present**: ESLint (Angular), Karma + Jasmine, Protractor, Jenkins (lint + test + build), TypeScript strict
- **Missing**: Modern E2E (Protractor deprecated), security, accessibility, dead code, formatting, git hooks
- **Key test**: Must flag Protractor as deprecated. Must detect @nguniversal as SSR indicator. Must detect Jenkins.

### 06-sveltekit
- **Framework**: SvelteKit | **Rendering**: SSR (adapter-node)
- **Expected Grade**: B
- **Present**: ESLint (flat config + svelte plugin), Prettier, Vitest, Playwright, GitHub Actions, svelte-check, TypeScript
- **Missing**: Security scanning, dead code, circular imports, git hooks, visual regression, coverage
- **Key test**: Must detect ESLint flat config format. Must detect adapter-node as SSR.

### 07-empty
- **Expected behavior**: Should report "no package.json found" and stop. Should NOT crash or produce a scorecard.

### 08-monorepo
- **Framework**: Turborepo + Next.js | **Rendering**: SSR
- **Expected Grade**: C
- **Present**: Root: Husky + lint-staged + Prettier + Turbo. Apps/web: ESLint + Vitest + Next.js. Packages/ui: ESLint + Vitest. GitHub Actions.
- **Missing**: Security, accessibility, E2E, dead code, circular imports, coverage, per-package type checking
- **Key test**: Must detect monorepo structure. Must check both apps/web and packages/ui. Must detect turbo.json.

### 09-gatsby-ssg
- **Framework**: Gatsby | **Rendering**: SSG
- **Expected Grade**: D
- **Present**: ESLint (basic), Jest, TypeScript strict
- **Missing**: CI, security, accessibility, formatting, E2E, dead code, circular imports, git hooks
- **Key test**: Must detect SSG (not SSR). Should NOT recommend SSR-specific tests (no getServerSideProps).

### 10-remix-full
- **Framework**: Remix | **Rendering**: SSR
- **Expected Grade**: A or B
- **Present**: ESLint + a11y + security, Prettier, TypeScript strict, Vitest + msw, Playwright, GitHub Actions (full), Snyk, knip, Dependabot, import/no-cycle, coverage thresholds
- **Missing**: Git hooks (no Husky), visual regression
- **Key test**: Should score high. Must detect Snyk AND Dependabot. Must detect import/no-cycle rule.

---

## Real Repo Battle Test Guide

For real repos, clone them and run the skill:

```bash
# Example: test against a Next.js app
git clone --depth 1 https://github.com/calcom/cal.com /tmp/test-calcom
/frontend-shift-left-audit /tmp/test-calcom
```

For real repos, you can't have exact expected answers, but verify:
- Framework detection is correct
- No tools are hallucinated (spot-check 3-4 claims against actual package.json)
- Recommendations make sense for the specific framework
- Report format matches the expected structure

---

## Aggregated Results Template

After running all tests, fill in:

```
| Repo | DevOps | FE DevOps | FE Dev | Skill Author | Grade Match | Overall |
|------|--------|-----------|--------|--------------|-------------|---------|
| 01-nextjs-bare | | | | | | |
| 02-nextjs-full | | | | | | |
| 03-vite-react-csr | | | | | | |
| 04-nuxt-ssr | | | | | | |
| 05-angular-enterprise | | | | | | |
| 06-sveltekit | | | | | | |
| 07-empty | | | | | | |
| 08-monorepo | | | | | | |
| 09-gatsby-ssg | | | | | | |
| 10-remix-full | | | | | | |
```
