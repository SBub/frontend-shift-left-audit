# Shift-Left Audit Reference

## Tool Detection Patterns

### ESLint Config Locations
- `.eslintrc.js`, `.eslintrc.cjs`, `.eslintrc.mjs`
- `.eslintrc.json`, `.eslintrc.yml`, `.eslintrc.yaml`
- `eslint.config.js`, `eslint.config.mjs`, `eslint.config.cjs` (flat config, ESLint 9+)
- `eslintConfig` field in `package.json`

### TypeScript Strict Mode Flags
When `strict: true` is set, it enables all of these:
- `noImplicitAny`, `strictNullChecks`, `strictFunctionTypes`
- `strictBindCallApply`, `strictPropertyInitialization`
- `noImplicitThis`, `alwaysStrict`, `useUnknownInCatchVariables`

### Framework-Specific SSR Indicators

| Framework | SSR Indicator | CSR/SSG Indicator |
|-----------|--------------|-------------------|
| Next.js | `getServerSideProps`, server components, App Router default | `output: 'export'`, `use client` only |
| Nuxt | `ssr: true` (default), `server/` dir | `ssr: false` in nuxt.config |
| Remix | Default (all routes are SSR) | `clientLoader` only routes |
| Gatsby | N/A (SSG by default) | `gatsby-ssr.js` for SSR elements |
| Angular | `@nguniversal/*` packages | No universal packages |
| SvelteKit | Default with `adapter-node` | `adapter-static`, `ssr: false` in routes |
| Astro | `output: 'server'` or `'hybrid'` | `output: 'static'` (default) |

### Security Tools Reference

| Tool | What It Catches | Relevant For | Install |
|------|----------------|-------------|---------|
| `eslint-plugin-security` | Unsafe regex, eval, non-literal require (14 rules) | **SSR/Hybrid** (all 14 rules); CSR (only ~6 rules - optional) | `npm i -D eslint-plugin-security` |
| `eslint-plugin-no-secrets` | Hardcoded secrets, API keys | All | `npm i -D eslint-plugin-no-secrets` |
| `eslint-plugin-no-unsanitized` | Unsafe DOM manipulation - `innerHTML`, `document.write` (XSS) | **CSR** (primary pick); SSR (if generating HTML) | `npm i -D eslint-plugin-no-unsanitized` |
| Snyk | Known vulnerabilities in deps | All | `npm i -D snyk` |
| `npm audit` | Known vulnerabilities in deps | All | Built-in |
| Dependabot | Automated dependency updates | All | GitHub config only |
| Socket | Supply chain attacks | All | `socket.yml` config |

**Verification:** For ESLint plugins, always confirm the plugin is loaded AND rules are enabled in the ESLint config. Check `extends`, `plugins`, and `rules` fields (legacy) or the flat config equivalent.

### Tree Shaking Verification

| Build Tool / Framework | Tree Shaking Status | How to Verify |
|----------------------|-------------------|---------------|
| Vite / Rollup | On by default | Always active - no config needed |
| Webpack | Conditional | `mode: 'production'` or `optimization.usedExports: true` in webpack config |
| Next.js | On by default | Production builds use Webpack/Turbopack with tree shaking enabled |
| Nuxt | On by default | Production builds via Vite (Nuxt 3) or Webpack (Nuxt 2 in production mode) |
| Angular | On by default | Production builds (`ng build`) enable tree shaking |
| Remix | On by default | Uses esbuild with tree shaking |
| SvelteKit | On by default | Uses Vite/Rollup |
| Gatsby | On by default | Uses Webpack production mode |
| Astro | On by default | Uses Vite/Rollup |
| CRA | On by default | Uses Webpack production mode |

### Test File Patterns
```
**/*.test.{js,jsx,ts,tsx}
**/*.spec.{js,jsx,ts,tsx}
**/__tests__/**/*.{js,jsx,ts,tsx}
**/tests/**/*.{js,jsx,ts,tsx}
cypress/**/*.cy.{js,ts}
e2e/**/*.{js,ts}
playwright/**/*.spec.{js,ts}
**/*.stories.{js,jsx,ts,tsx}  (Storybook, enables visual testing)
```

### CI Step Detection Patterns

| Step | Patterns to Search In CI Files |
|------|-------------------------------|
| Type check | `tsc`, `vue-tsc`, `tsc --noEmit` |
| Lint | `eslint`, `biome check`, `oxlint`, `lint` |
| Format | `prettier --check`, `biome format`, `format:check` |
| Unit test | `jest`, `vitest`, `test:unit`, `npm test`, `mocha` |
| E2E test | `playwright`, `cypress`, `test:e2e` |
| Build | `build`, `next build`, `nuxt build`, `vite build` |
| Security | `npm audit`, `snyk test`, `audit` |
| Coverage | `--coverage`, `codecov`, `coveralls` |
| Bundle | `bundle-analyzer`, `size-limit`, `bundlewatch` |
