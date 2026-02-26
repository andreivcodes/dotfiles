# Global Agent Guidelines

This file contains critical rules that apply across all OpenCode sessions for the personal profile.

## Critical Rules

### Git Operations

**CRITICAL**: Under no circumstance should you commit or push changes without asking for explicit permission first. Always ask the user before running any `git commit`, `git push`, or `git add` commands.

**Pre-Commit Validation**: When the user asks you to commit changes, you MUST perform the following steps before creating the commit:

1. **Run Linting**: Execute the project's linter (e.g., `oxlint`, `eslint`, `prettier --check`, `shellcheck`, `ruff`, etc.) and fix any issues found.
2. **Run Build**: Execute the project's build command (e.g., `npm run build`, `cargo build`, `go build`, etc.) and ensure it completes successfully.
3. **Run Tests**: Run a representative subset of the test suite to verify nothing is broken. You don't need to run the entire test suite, but you should:
   - Run tests related to the files you modified
   - Run a quick smoke test or unit test suite if available
   - For example: `npm test -- --related`, `pytest -x`, or run tests in the same directory as changed files

If any of these steps fail, fix the issues before proceeding with the commit. Only after all validations pass should you proceed with the commit.

**Commit Message Best Practices**: When the user requests a commit, follow these conventions:

1. **Subject Line** (first line):
   - Limit to 50 characters (72 character hard limit)
   - Capitalize the first letter
   - Do not end with a period
   - Use imperative mood (e.g., "Add feature" not "Added feature" or "Adds feature")
   - Should complete the sentence: "If applied, this commit will [your subject line]"

2. **Body** (optional, after blank line):
   - Wrap at 72 characters
   - Explain *what* and *why*, not *how*
   - Focus on the problem being solved and why this approach was chosen
   - Include side effects or non-obvious consequences if relevant

3. **Format Example**:
   ```
   Summarize changes in around 50 characters or less

   More detailed explanatory text, if necessary. Wrap it to about 72
   characters or so. The blank line separating the summary from the
   body is critical.

   Explain the problem that this commit is solving. Focus on why you
   are making this change as opposed to how (the code explains that).

   - Bullet points are okay, too
   - Use a hyphen or asterisk with a single space

   Resolves: #123
   ```

**CRITICAL - No AI Attribution**: NEVER add any of the following to commit messages, PR descriptions, code comments, or any other content:
- `Co-Authored-By:` lines mentioning any AI or assistant
- `🤖 Generated with` or similar footers
- Any mention of AI, Claude, OpenCode, Codex, assistant, or automated generation
- Any attribution signatures or watermarks indicating AI involvement

Commit messages should read as if written by the human developer. The user does not want AI attribution in their git history or codebase.

### File Management

**CRITICAL**: Do not write summary files, documentation files, or reference files in the project directory unless explicitly asked to do so after finishing a task. If you need to create summary files for reference purposes, write them to the `/tmp` folder instead.

### Handling User Corrections

**CRITICAL**: When the user attempts to correct you or challenges your approach, do NOT automatically agree or capitulate. Instead:

1. **Verify the correction**: Investigate whether the user's correction is actually accurate. Check the code, documentation, or run tests to confirm.
2. **Trust but verify**: The user may have outdated information, misremember details, or misunderstand the current state of the code.
3. **Respectfully disagree when warranted**: If your original approach was correct, explain why with evidence (code references, test results, documentation).
4. **Acknowledge genuine mistakes**: If the user's correction is valid, acknowledge it clearly and adjust your approach.

The goal is to arrive at the correct solution, not to please the user by agreeing with everything they say. Sycophantic agreement can lead to worse outcomes for the codebase.
