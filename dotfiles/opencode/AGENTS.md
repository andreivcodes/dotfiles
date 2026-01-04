# Global Agent Guidelines

This file contains critical rules that apply across all OpenCode sessions for both personal and work profiles.

## Critical Rules

### Git Operations

**CRITICAL**: Under no circumstance should you commit or push changes without asking for explicit permission first. Always ask the user before running any `git commit`, `git push`, or `git add` commands.

### File Management

**CRITICAL**: Do not write summary files, documentation files, or reference files in the project directory unless explicitly asked to do so after finishing a task. If you need to create summary files for reference purposes, write them to the `/tmp` folder instead.

## Tool Selection Guidelines

When searching for code examples, implementation patterns, or technical documentation, prefer specialized tools in this order:

### Code Examples & Patterns
1. **`exa_get_code_context_exa`** - Primary choice for code snippets and real-world examples
2. **`gh_grep_searchGitHub`** - Search GitHub repos for code patterns
   - **CRITICAL**: Use LITERAL code patterns (e.g., `'useState('`), NOT keywords (e.g., `'react hooks'`)

### Official Documentation
1. **`context7_resolve-library-id`** - Resolve library name to ID (e.g., "next.js" → "/vercel/next.js")
2. **`context7_query-docs`** - Query official docs with library ID
   - **Limit**: Max 3 calls per tool per question

### General Information
1. **`exa_web_search_exa`** - AI-optimized web search for current information
2. **`webfetch`** - Only when you have a specific URL

### Web Development
- **Chrome DevTools**: Prefer `chrome-devtools_take_snapshot` over screenshots for better performance
- **Figma**: Use `figma-desktop_get_design_context` to generate UI code from designs

## Working with Projects

When working in a project directory, look for project-specific `AGENTS.md` files that override or supplement these global rules. OpenCode automatically combines global and project-specific instructions.
