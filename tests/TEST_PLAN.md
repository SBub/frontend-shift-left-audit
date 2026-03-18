# Frontend Shift-Left Audit - Test Plan

## Testing Strategy

This skill is tested by a team of specialized agent personas, each evaluating the audit from their professional perspective. Tests run against both synthetic mock repos and real open-source repos.

---

## Agent Personas

### 1. DevOps Engineer (CI/CD Specialist)
**Focus**: CI/CD pipeline detection accuracy and recommendation quality
**Evaluates**:
- Does the audit correctly identify ALL CI platforms in use?
- Does it accurately parse workflow files and detect which checks run in CI?
- Are pipeline gap recommendations actionable (correct YAML snippets, right syntax for the platform)?
- Does it distinguish between "tool installed but not in CI" vs "tool in CI"?
- For monorepos: does it detect per-package CI jobs?

**Pass criteria**:
- Zero false positives on CI platform detection
- Correctly identifies at least 90% of CI steps
- Recommendations use correct CI syntax for the detected platform

### 2. Frontend DevOps Engineer (Tooling Specialist)
**Focus**: Static analysis tool detection accuracy
**Evaluates**:
- Does it detect ESLint flat config vs legacy config correctly?
- Does it read ESLint rules to check for specific plugins (security, a11y)?
- Does it detect Biome as an ESLint alternative (not mark linting as "missing")?
- Does it handle TypeScript strict mode detection correctly?
- Does it detect pre-commit hooks and what they run?
- For SSR: does it check for server-specific security (helmet, CSP headers)?
- Does it correctly detect the package manager?

**Pass criteria**:
- Zero false negatives on installed tools
- Correctly distinguishes "installed" from "configured" from "CI-integrated"
- Framework detection is 100% accurate
- Rendering strategy detection is correct

### 3. Frontend Developer (Consumer of the Report)
**Focus**: Actionability and clarity of output
**Evaluates**:
- Is the report easy to scan? Can I find critical gaps in under 10 seconds?
- Are recommendations specific (not generic "add testing")? Do they include install commands?
- Are "Quick Wins" actually quick? Could I do them in 30 minutes?
- Does the scoring feel fair? Is a well-tested repo getting an A?
- Are framework-specific recommendations relevant to MY framework?
- Does it avoid false alarms that would waste my time?

**Pass criteria**:
- Every recommendation includes a concrete command or config snippet
- Quick wins are genuinely implementable in 30 min
- Scoring matches intuitive assessment of repo quality
- No irrelevant framework recommendations

### 4. Skill Author (Quality Reviewer)
**Focus**: Skill structure, robustness, edge cases
**Evaluates**:
- Does the skill handle empty repos gracefully?
- Does it work with monorepos?
- Does it handle repos with no package.json?
- Is the skill prompt clear enough that different Claude models produce consistent results?
- Are there any ambiguous instructions that could lead to hallucinated findings?
- Does the report format stay consistent across different repos?
- Is the skill under 500 lines? Is reference material properly separated?

**Pass criteria**:
- Consistent output format across all test repos
- No crashes or hallucinated tool detections
- Clean separation between skill instructions and reference data

---

## Test Scenarios

### Tier 1: Synthetic Mock Repos (controlled, known-good answers)

Each mock repo is a minimal directory structure with specific tools present/absent so we can verify exact detection accuracy.

| # | Scenario | Framework | Rendering | Tools Present | Expected Gaps |
|---|----------|-----------|-----------|---------------|---------------|
| 1 | Bare minimum | Next.js 14 | SSR (App Router) | ESLint (basic), TS (non-strict), Jest (no tests) | Security, A11y, E2E, CI, Dead code, Circular imports, Git hooks |
| 2 | Well-equipped | Next.js 14 | SSR | ESLint + security + a11y, TS strict, Vitest + msw + Playwright, Husky + lint-staged, GitHub Actions (full) | Visual regression |
| 3 | CSR basic | Vite + React | CSR | Biome (linter+formatter), Vitest, no CI | CI integration, Security, A11y, E2E |
| 4 | Vue SSR | Nuxt 3 | SSR | ESLint + @nuxt/eslint, Vitest, Cypress, GitLab CI | Security, Dead code, Circular imports |
| 5 | Angular enterprise | Angular 17 | CSR + SSR (Universal) | ESLint, Karma+Jasmine, Protractor (deprecated), Jenkins | Recommend Playwright over Protractor, missing modern tools |
| 6 | SvelteKit | SvelteKit | SSR | ESLint + svelte plugin, Vitest, Playwright, GitHub Actions | Security scanning, dead code, visual regression |
| 7 | Empty repo | None | None | Empty directory with git init | Should report "no package.json" and stop |
| 8 | Monorepo | Turborepo + Next.js + shared libs | SSR | Root: Husky, lint-staged. Packages: mixed tooling | Should audit each package |
| 9 | Gatsby SSG | Gatsby | SSG | ESLint, Jest, no CI | Should detect SSG, not recommend SSR-specific tests |
| 10 | Remix full | Remix | SSR | ESLint, Vitest, Playwright, GitHub Actions, Snyk | Should score high, minimal gaps |

### Tier 2: Real Open-Source Repos (battle testing)

| # | Repo | Framework | Rendering | Why This Repo |
|---|------|-----------|-----------|--------------|
| 1 | `vercel/next.js` (examples/with-jest) | Next.js | SSR | Reference Next.js setup |
| 2 | `nuxt/nuxt.com` | Nuxt | SSR | Official Nuxt site |
| 3 | `remix-run/indie-stack` | Remix | SSR | Remix starter template |
| 4 | `withastro/astro.build` | Astro | SSG/SSR | Astro official site |
| 5 | `sveltejs/realworld` | SvelteKit | SSR | SvelteKit reference app |
| 6 | `angular/angular` | Angular | CSR | Large-scale enterprise Angular |
| 7 | `vitejs/vite` | Vite (meta) | CSR | Well-maintained OSS project |
| 8 | `calcom/cal.com` | Next.js | SSR | Complex monorepo, real product |
| 9 | `shadcn-ui/ui` | Next.js | CSR/SSG | Popular component library |
| 10 | `t3-oss/create-t3-app` | Next.js | SSR | Modern full-stack template |

---

## Test Execution Process

### Step 1: Generate Mock Repos
Run `generate-mocks.sh` to create synthetic test repos.

### Step 2: Run Skill Against Each Repo
For each test repo, invoke: `/frontend-shift-left-audit <path-to-repo>`

### Step 3: Agent Evaluation
Each persona agent reviews every audit output against their criteria. They produce:
- **PASS/FAIL** per criterion
- **Issues found** (with severity: critical, major, minor)
- **Suggestions** for skill improvement

### Step 4: Aggregate Results
```
| Repo | DevOps | FE DevOps | FE Dev | Skill Author | Overall |
|------|--------|-----------|--------|--------------|---------|
| ...  | PASS   | PASS      | FAIL   | PASS         | FAIL    |
```

A repo test passes only if ALL personas pass.

### Step 5: Iterate
Fix issues found, re-run failing tests until all pass.

---

## Acceptance Criteria

The skill is considered battle-tested when:
1. All 10 synthetic mock scenarios pass all 4 personas
2. At least 8 of 10 real-world repos produce accurate, actionable reports
3. Zero false positives on tool detection across all tests
4. Report format is consistent across all runs
5. Framework-specific recommendations are always relevant to the detected framework
