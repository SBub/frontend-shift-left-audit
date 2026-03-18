#!/bin/bash
# Generate synthetic test repos for frontend-shift-left-audit skill testing
# Each repo has a known set of tools to verify detection accuracy

BASE_DIR="${1:-/tmp/shift-left-audit-test-repos}"
rm -rf "$BASE_DIR"
mkdir -p "$BASE_DIR"

echo "Generating mock repos in $BASE_DIR..."

# ============================================================
# Mock 1: Next.js SSR - Bare minimum
# ============================================================
REPO="$BASE_DIR/01-nextjs-bare"
mkdir -p "$REPO/src/app" "$REPO/src/components"

cat > "$REPO/package.json" << 'EOF'
{
  "name": "nextjs-bare",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint .",
    "test": "jest"
  },
  "dependencies": {
    "next": "14.2.0",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  },
  "devDependencies": {
    "eslint": "8.56.0",
    "eslint-config-next": "14.2.0",
    "jest": "29.7.0",
    "typescript": "5.3.3"
  }
}
EOF

cat > "$REPO/.eslintrc.json" << 'EOF'
{
  "extends": "next/core-web-vitals"
}
EOF

cat > "$REPO/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "es2017"],
    "strict": false,
    "module": "esnext",
    "jsx": "preserve"
  }
}
EOF

cat > "$REPO/next.config.js" << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {}
module.exports = nextConfig
EOF

cat > "$REPO/jest.config.js" << 'EOF'
module.exports = { testEnvironment: 'jsdom' }
EOF

# No test files, no CI, no security, no a11y, no hooks
cat > "$REPO/src/app/page.tsx" << 'EOF'
export default function Home() {
  return <h1>Hello</h1>
}
EOF

echo "  Created: 01-nextjs-bare"

# ============================================================
# Mock 2: Next.js SSR - Well-equipped
# ============================================================
REPO="$BASE_DIR/02-nextjs-full"
mkdir -p "$REPO/src/app" "$REPO/src/components" "$REPO/src/__tests__" \
         "$REPO/e2e" "$REPO/.husky" "$REPO/.github/workflows"

cat > "$REPO/package.json" << 'EOF'
{
  "name": "nextjs-full",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint . --max-warnings 0",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "knip": "knip",
    "prepare": "husky"
  },
  "dependencies": {
    "next": "14.2.0",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  },
  "devDependencies": {
    "eslint": "8.56.0",
    "eslint-config-next": "14.2.0",
    "eslint-plugin-security": "2.1.0",
    "eslint-plugin-jsx-a11y": "6.8.0",
    "eslint-plugin-no-secrets": "0.8.9",
    "@typescript-eslint/eslint-plugin": "7.0.0",
    "typescript": "5.3.3",
    "prettier": "3.2.0",
    "vitest": "1.2.0",
    "@testing-library/react": "14.2.0",
    "@vitejs/plugin-react": "4.2.0",
    "msw": "2.1.0",
    "@playwright/test": "1.41.0",
    "axe-core": "4.8.0",
    "@axe-core/playwright": "4.8.0",
    "knip": "4.3.0",
    "husky": "9.0.0",
    "lint-staged": "15.2.0",
    "@vitest/coverage-v8": "1.2.0"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md}": ["prettier --write"]
  }
}
EOF

cat > "$REPO/.eslintrc.json" << 'EOF'
{
  "extends": [
    "next/core-web-vitals",
    "plugin:@typescript-eslint/recommended",
    "plugin:jsx-a11y/recommended",
    "plugin:security/recommended-legacy"
  ],
  "plugins": ["no-secrets"],
  "rules": {
    "no-secrets/no-secrets": "error",
    "import/no-cycle": "error"
  }
}
EOF

cat > "$REPO/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "es2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "strict": true,
    "module": "esnext",
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }]
  }
}
EOF

cat > "$REPO/next.config.js" << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {}
module.exports = nextConfig
EOF

cat > "$REPO/vitest.config.ts" << 'EOF'
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    coverage: {
      provider: 'v8',
      thresholds: { lines: 80, functions: 80, branches: 70 }
    }
  }
})
EOF

cat > "$REPO/playwright.config.ts" << 'EOF'
import { defineConfig } from '@playwright/test'
export default defineConfig({
  testDir: './e2e',
  use: { baseURL: 'http://localhost:3000' },
  webServer: { command: 'npm run build && npm start', port: 3000 }
})
EOF

cat > "$REPO/.prettierrc" << 'EOF'
{ "semi": false, "singleQuote": true, "trailingComma": "all" }
EOF

cat > "$REPO/knip.ts" << 'EOF'
import type { KnipConfig } from 'knip'
const config: KnipConfig = { entry: ['src/app/**/*.tsx'] }
export default config
EOF

cat > "$REPO/.husky/pre-commit" << 'EOF'
npx lint-staged
EOF
chmod +x "$REPO/.husky/pre-commit"

cat > "$REPO/.github/workflows/ci.yml" << 'EOF'
name: CI
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run type-check
      - run: npm run lint
      - run: npm run format:check
      - run: npm run test:coverage
      - run: npm run knip
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run test:e2e
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --audit-level=high
EOF

cat > "$REPO/src/__tests__/Home.test.tsx" << 'EOF'
import { render, screen } from '@testing-library/react'
import Home from '../app/page'
import { describe, it, expect } from 'vitest'

describe('Home', () => {
  it('renders heading', () => {
    render(<Home />)
    expect(screen.getByRole('heading')).toBeDefined()
  })
})
EOF

cat > "$REPO/e2e/home.spec.ts" << 'EOF'
import { test, expect } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

test('homepage loads', async ({ page }) => {
  await page.goto('/')
  await expect(page.getByRole('heading')).toBeVisible()
})

test('accessibility check', async ({ page }) => {
  await page.goto('/')
  const results = await new AxeBuilder({ page }).analyze()
  expect(results.violations).toEqual([])
})
EOF

echo "  Created: 02-nextjs-full"

# ============================================================
# Mock 3: Vite + React CSR - Biome, no CI
# ============================================================
REPO="$BASE_DIR/03-vite-react-csr"
mkdir -p "$REPO/src" "$REPO/src/__tests__"

cat > "$REPO/package.json" << 'EOF'
{
  "name": "vite-react-app",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "check": "biome check .",
    "test": "vitest run"
  },
  "dependencies": {
    "react": "18.2.0",
    "react-dom": "18.2.0"
  },
  "devDependencies": {
    "@biomejs/biome": "1.5.0",
    "vite": "5.0.0",
    "@vitejs/plugin-react": "4.2.0",
    "vitest": "1.2.0",
    "@testing-library/react": "14.2.0",
    "typescript": "5.3.3"
  }
}
EOF

cat > "$REPO/biome.json" << 'EOF'
{
  "$schema": "https://biomejs.dev/schemas/1.5.0/schema.json",
  "organizeImports": { "enabled": true },
  "linter": {
    "enabled": true,
    "rules": { "recommended": true }
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2
  }
}
EOF

cat > "$REPO/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "strict": true,
    "jsx": "react-jsx"
  }
}
EOF

cat > "$REPO/vite.config.ts" << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({ plugins: [react()] })
EOF

cat > "$REPO/vitest.config.ts" << 'EOF'
import { defineConfig } from 'vitest/config'
export default defineConfig({
  test: { environment: 'jsdom' }
})
EOF

cat > "$REPO/src/__tests__/App.test.tsx" << 'EOF'
import { render } from '@testing-library/react'
import { describe, it, expect } from 'vitest'

describe('App', () => {
  it('renders', () => {
    const { container } = render(<div>test</div>)
    expect(container).toBeDefined()
  })
})
EOF

echo "  Created: 03-vite-react-csr"

# ============================================================
# Mock 4: Nuxt 3 SSR - ESLint + Vitest + Cypress + GitLab CI
# ============================================================
REPO="$BASE_DIR/04-nuxt-ssr"
mkdir -p "$REPO/server/api" "$REPO/pages" "$REPO/tests" "$REPO/cypress/e2e"

cat > "$REPO/package.json" << 'EOF'
{
  "name": "nuxt-ssr-app",
  "version": "1.0.0",
  "scripts": {
    "dev": "nuxt dev",
    "build": "nuxt build",
    "generate": "nuxt generate",
    "lint": "eslint .",
    "test": "vitest run",
    "test:e2e": "cypress run"
  },
  "dependencies": {
    "nuxt": "3.10.0",
    "vue": "3.4.0"
  },
  "devDependencies": {
    "@nuxt/eslint": "0.1.0",
    "eslint": "8.56.0",
    "@nuxtjs/eslint-config-typescript": "12.1.0",
    "vitest": "1.2.0",
    "@vue/test-utils": "2.4.0",
    "cypress": "13.6.0",
    "typescript": "5.3.3",
    "eslint-plugin-vuejs-accessibility": "2.2.0"
  }
}
EOF

cat > "$REPO/nuxt.config.ts" << 'EOF'
export default defineNuxtConfig({
  ssr: true,
  devtools: { enabled: true },
  modules: ['@nuxt/eslint']
})
EOF

cat > "$REPO/.eslintrc.cjs" << 'EOF'
module.exports = {
  extends: [
    '@nuxtjs/eslint-config-typescript',
    'plugin:vuejs-accessibility/recommended'
  ]
}
EOF

cat > "$REPO/tsconfig.json" << 'EOF'
{ "extends": "./.nuxt/tsconfig.json" }
EOF

cat > "$REPO/.gitlab-ci.yml" << 'EOF'
stages:
  - quality
  - test
  - build

lint:
  stage: quality
  script:
    - npm ci
    - npm run lint

unit-test:
  stage: test
  script:
    - npm ci
    - npm run test

e2e-test:
  stage: test
  script:
    - npm ci
    - npm run build
    - npm run test:e2e

build:
  stage: build
  script:
    - npm ci
    - npm run build
EOF

cat > "$REPO/cypress.config.ts" << 'EOF'
import { defineConfig } from 'cypress'
export default defineConfig({
  e2e: { baseUrl: 'http://localhost:3000' }
})
EOF

cat > "$REPO/tests/index.test.ts" << 'EOF'
import { describe, it, expect } from 'vitest'
describe('Index page', () => {
  it('placeholder', () => { expect(true).toBe(true) })
})
EOF

echo "  Created: 04-nuxt-ssr"

# ============================================================
# Mock 5: Angular enterprise - legacy tooling
# ============================================================
REPO="$BASE_DIR/05-angular-enterprise"
mkdir -p "$REPO/src/app" "$REPO/e2e"

cat > "$REPO/package.json" << 'EOF'
{
  "name": "angular-enterprise",
  "version": "1.0.0",
  "scripts": {
    "ng": "ng",
    "start": "ng serve",
    "build": "ng build",
    "test": "ng test",
    "lint": "ng lint",
    "e2e": "protractor"
  },
  "dependencies": {
    "@angular/core": "17.0.0",
    "@angular/platform-browser": "17.0.0",
    "@angular/platform-server": "17.0.0",
    "@nguniversal/express-engine": "17.0.0"
  },
  "devDependencies": {
    "@angular/cli": "17.0.0",
    "@angular-eslint/builder": "17.0.0",
    "@angular-eslint/eslint-plugin": "17.0.0",
    "@angular-eslint/eslint-plugin-template": "17.0.0",
    "eslint": "8.56.0",
    "karma": "6.4.0",
    "karma-jasmine": "5.1.0",
    "karma-chrome-launcher": "3.2.0",
    "jasmine-core": "5.1.0",
    "protractor": "7.0.0",
    "typescript": "5.2.0"
  }
}
EOF

cat > "$REPO/angular.json" << 'EOF'
{
  "$schema": "./node_modules/@angular/cli/lib/config/schema.json",
  "projects": {
    "angular-enterprise": {
      "architect": {
        "build": { "builder": "@angular-devkit/build-angular:application" },
        "serve": { "builder": "@angular-devkit/build-angular:dev-server" },
        "test": { "builder": "@angular-devkit/build-angular:karma" },
        "lint": { "builder": "@angular-eslint/builder:lint" },
        "server": { "builder": "@angular-devkit/build-angular:server" }
      }
    }
  }
}
EOF

cat > "$REPO/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "ES2022"
  },
  "angularCompilerOptions": {
    "strictInjectionParameters": true,
    "strictTemplates": false
  }
}
EOF

cat > "$REPO/.eslintrc.json" << 'EOF'
{
  "extends": ["plugin:@angular-eslint/recommended"]
}
EOF

# Jenkins CI
cat > "$REPO/Jenkinsfile" << 'EOF'
pipeline {
  agent any
  stages {
    stage('Install') { steps { sh 'npm ci' } }
    stage('Lint') { steps { sh 'npm run lint' } }
    stage('Test') { steps { sh 'npm run test -- --no-watch --code-coverage' } }
    stage('Build') { steps { sh 'npm run build' } }
  }
}
EOF

echo "  Created: 05-angular-enterprise"

# ============================================================
# Mock 6: SvelteKit SSR - modern setup
# ============================================================
REPO="$BASE_DIR/06-sveltekit"
mkdir -p "$REPO/src/routes" "$REPO/tests" "$REPO/e2e" "$REPO/.github/workflows"

cat > "$REPO/package.json" << 'EOF'
{
  "name": "sveltekit-app",
  "version": "1.0.0",
  "scripts": {
    "dev": "vite dev",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint .",
    "format": "prettier --write .",
    "check": "svelte-check",
    "test": "vitest run",
    "test:e2e": "playwright test"
  },
  "dependencies": {
    "@sveltejs/kit": "2.0.0",
    "svelte": "4.2.0"
  },
  "devDependencies": {
    "@sveltejs/adapter-node": "2.0.0",
    "eslint": "8.56.0",
    "eslint-plugin-svelte": "2.35.0",
    "prettier": "3.2.0",
    "prettier-plugin-svelte": "3.1.0",
    "svelte-check": "3.6.0",
    "vitest": "1.2.0",
    "@playwright/test": "1.41.0",
    "typescript": "5.3.3"
  }
}
EOF

cat > "$REPO/svelte.config.js" << 'EOF'
import adapter from '@sveltejs/adapter-node'
export default { kit: { adapter: adapter() } }
EOF

cat > "$REPO/eslint.config.js" << 'EOF'
import svelte from 'eslint-plugin-svelte'
export default [
  ...svelte.configs['flat/recommended'],
  { rules: { 'svelte/no-at-html-tags': 'error' } }
]
EOF

cat > "$REPO/.prettierrc" << 'EOF'
{ "plugins": ["prettier-plugin-svelte"], "singleQuote": true }
EOF

cat > "$REPO/.github/workflows/ci.yml" << 'EOF'
name: CI
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run check
      - run: npm run lint
      - run: npm run format -- --check
      - run: npm run test
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run test:e2e
EOF

cat > "$REPO/playwright.config.ts" << 'EOF'
import { defineConfig } from '@playwright/test'
export default defineConfig({
  testDir: 'e2e',
  webServer: { command: 'npm run build && npm run preview', port: 4173 }
})
EOF

cat > "$REPO/tests/routes.test.ts" << 'EOF'
import { describe, it, expect } from 'vitest'
describe('routes', () => { it('loads', () => { expect(true).toBe(true) }) })
EOF

echo "  Created: 06-sveltekit"

# ============================================================
# Mock 7: Empty repo
# ============================================================
REPO="$BASE_DIR/07-empty"
mkdir -p "$REPO"
cd "$REPO" && git init -q && cd -

echo "  Created: 07-empty"

# ============================================================
# Mock 8: Turborepo monorepo
# ============================================================
REPO="$BASE_DIR/08-monorepo"
mkdir -p "$REPO/apps/web/src" "$REPO/apps/web/.github" \
         "$REPO/packages/ui/src" "$REPO/.husky" "$REPO/.github/workflows"

cat > "$REPO/package.json" << 'EOF'
{
  "name": "monorepo",
  "private": true,
  "workspaces": ["apps/*", "packages/*"],
  "scripts": {
    "build": "turbo build",
    "lint": "turbo lint",
    "test": "turbo test",
    "format": "prettier --write .",
    "prepare": "husky"
  },
  "devDependencies": {
    "turbo": "1.12.0",
    "prettier": "3.2.0",
    "husky": "9.0.0",
    "lint-staged": "15.2.0"
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"]
  }
}
EOF

cat > "$REPO/turbo.json" << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": { "dependsOn": ["^build"] },
    "lint": {},
    "test": {}
  }
}
EOF

cat > "$REPO/apps/web/package.json" << 'EOF'
{
  "name": "web",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "lint": "eslint .",
    "test": "vitest run"
  },
  "dependencies": {
    "next": "14.2.0",
    "react": "18.2.0",
    "ui": "*"
  },
  "devDependencies": {
    "eslint": "8.56.0",
    "eslint-config-next": "14.2.0",
    "vitest": "1.2.0",
    "typescript": "5.3.3"
  }
}
EOF

cat > "$REPO/apps/web/next.config.js" << 'EOF'
module.exports = {}
EOF

cat > "$REPO/packages/ui/package.json" << 'EOF'
{
  "name": "ui",
  "version": "1.0.0",
  "main": "src/index.ts",
  "scripts": {
    "lint": "eslint .",
    "test": "vitest run"
  },
  "devDependencies": {
    "eslint": "8.56.0",
    "vitest": "1.2.0",
    "typescript": "5.3.3"
  }
}
EOF

cat > "$REPO/.husky/pre-commit" << 'EOF'
npx lint-staged
EOF
chmod +x "$REPO/.husky/pre-commit"

cat > "$REPO/.github/workflows/ci.yml" << 'EOF'
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run lint
      - run: npm run test
      - run: npm run build
EOF

echo "  Created: 08-monorepo"

# ============================================================
# Mock 9: Gatsby SSG
# ============================================================
REPO="$BASE_DIR/09-gatsby-ssg"
mkdir -p "$REPO/src/pages" "$REPO/src/__tests__"

cat > "$REPO/package.json" << 'EOF'
{
  "name": "gatsby-site",
  "version": "1.0.0",
  "scripts": {
    "develop": "gatsby develop",
    "build": "gatsby build",
    "serve": "gatsby serve",
    "lint": "eslint src/",
    "test": "jest"
  },
  "dependencies": {
    "gatsby": "5.13.0",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  },
  "devDependencies": {
    "eslint": "8.56.0",
    "eslint-plugin-react": "7.33.0",
    "jest": "29.7.0",
    "@testing-library/react": "14.2.0",
    "typescript": "5.3.3"
  }
}
EOF

cat > "$REPO/gatsby-config.ts" << 'EOF'
import type { GatsbyConfig } from 'gatsby'
const config: GatsbyConfig = {
  siteMetadata: { title: 'Gatsby Site' },
  plugins: ['gatsby-plugin-image']
}
export default config
EOF

cat > "$REPO/.eslintrc.json" << 'EOF'
{ "extends": ["eslint:recommended", "plugin:react/recommended"] }
EOF

cat > "$REPO/tsconfig.json" << 'EOF'
{ "compilerOptions": { "strict": true, "jsx": "react-jsx" } }
EOF

cat > "$REPO/src/__tests__/index.test.tsx" << 'EOF'
import { render } from '@testing-library/react'
import React from 'react'
test('renders', () => { render(<div>test</div>) })
EOF

echo "  Created: 09-gatsby-ssg"

# ============================================================
# Mock 10: Remix SSR - well-equipped
# ============================================================
REPO="$BASE_DIR/10-remix-full"
mkdir -p "$REPO/app/routes" "$REPO/tests" "$REPO/e2e" "$REPO/.github/workflows"

cat > "$REPO/package.json" << 'EOF'
{
  "name": "remix-app",
  "version": "1.0.0",
  "scripts": {
    "dev": "remix vite:dev",
    "build": "remix vite:build",
    "start": "remix-serve ./build/server/index.js",
    "lint": "eslint --max-warnings 0 .",
    "format:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    "test": "vitest run",
    "test:e2e": "playwright test"
  },
  "dependencies": {
    "@remix-run/node": "2.5.0",
    "@remix-run/react": "2.5.0",
    "@remix-run/serve": "2.5.0",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  },
  "devDependencies": {
    "@remix-run/dev": "2.5.0",
    "eslint": "8.56.0",
    "eslint-plugin-jsx-a11y": "6.8.0",
    "eslint-plugin-security": "2.1.0",
    "prettier": "3.2.0",
    "typescript": "5.3.3",
    "vitest": "1.2.0",
    "@testing-library/react": "14.2.0",
    "msw": "2.1.0",
    "@playwright/test": "1.41.0",
    "snyk": "1.1260.0",
    "knip": "4.3.0"
  }
}
EOF

cat > "$REPO/.eslintrc.cjs" << 'EOF'
module.exports = {
  extends: [
    'eslint:recommended',
    'plugin:jsx-a11y/recommended',
    'plugin:security/recommended-legacy'
  ],
  rules: {
    'import/no-cycle': 'error'
  }
}
EOF

cat > "$REPO/tsconfig.json" << 'EOF'
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "jsx": "react-jsx"
  }
}
EOF

cat > "$REPO/vitest.config.ts" << 'EOF'
import { defineConfig } from 'vitest/config'
export default defineConfig({
  test: {
    environment: 'jsdom',
    coverage: { provider: 'v8', thresholds: { lines: 70 } }
  }
})
EOF

cat > "$REPO/playwright.config.ts" << 'EOF'
import { defineConfig } from '@playwright/test'
export default defineConfig({
  testDir: 'e2e',
  webServer: { command: 'npm run build && npm start', port: 3000 }
})
EOF

cat > "$REPO/knip.ts" << 'EOF'
export default { entry: ['app/**/*.{ts,tsx}'] }
EOF

cat > "$REPO/.github/workflows/ci.yml" << 'EOF'
name: CI
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run type-check
      - run: npm run lint
      - run: npm run format:check
      - run: npm run test
      - run: npm run knip
      - run: npx snyk test
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run test:e2e
EOF

cat > "$REPO/.github/dependabot.yml" << 'EOF'
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule: { interval: "weekly" }
EOF

echo "  Created: 10-remix-full"

echo ""
echo "All 10 mock repos generated in: $BASE_DIR"
echo ""
echo "To test: /frontend-shift-left-audit $BASE_DIR/<repo-name>"
