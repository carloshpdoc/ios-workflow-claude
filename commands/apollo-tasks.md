# Create Apollo Migration Jira Tasks

Create Jira tasks for Apollo GraphQL migration repositories.

## Usage

```
/apollo-tasks <RepoName1> <RepoName2> ...
```

Or without arguments to use the recommended next repositories from `/apollo-status`.

## Arguments

- `$ARGUMENTS` - Space-separated list of repository names to create tasks for (optional)

## Jira Configuration

- **Project:** {{TICKET_PREFIX}}
- **Cloud ID:** {{JIRA_CLOUD_ID}}
- **Epic:** {{TICKET_PREFIX}}-XXXX (Apollo Removal)
- **Labels:** apollo-removal, tech-debt
- **Assignee:** {{JIRA_ASSIGNEE_ID}} (current user)
- **Sprint field:** customfield_10020

## Steps

### 1. Get Repository List

If `$ARGUMENTS` is provided, parse the space-separated repository names.

If no arguments, run `/apollo-status` logic to get the recommended next 5 repositories from `docs/apollo-migration-status.md`.

### 2. Gather Repository Details

For each repository, search the codebase to find:
- **Location:** The directory path (e.g., `{{APP}}/Repositories/<RepoName>/`)
- **Consumers:** Files that import/use the repository (ViewModels, Factories, Builders)
- **Tier:** Complexity tier (1=simple, 2=medium, 3=complex) based on number of queries/mutations

### 3. Find Current Sprint

Use `mcp__claude_ai_Atlassian__getJiraIssue` to get an existing Apollo task (e.g., {{TICKET_PREFIX}}-XXXX) and extract the active sprint ID from `customfield_10020`.

### 4. Create Jira Tasks

For each repository, use `mcp__claude_ai_Atlassian__createJiraIssue` with:

```
cloudId: {{JIRA_CLOUD_ID}}
projectKey: {{TICKET_PREFIX}}
issueTypeName: Task
summary: [APOLLO] Migrate <RepoName> repository to GraphQLClientProtocol
contentFormat: markdown
assignee_account_id: {{JIRA_ASSIGNEE_ID}}
additional_fields: {"labels": ["apollo-removal", "tech-debt"]}
description: |
  ## Overview
  Migrate Network<RepoName>Repository from Apollo to GraphQLClientProtocol.

  ## Tier
  <tier> (<complexity description>)

  ## Location
  `<location>`

  ## Consumers (<count>)
  - <Consumer1>
  - <Consumer2>
  ...

  ## Tasks
  - Create Query file
  - Create DataSource file
  - Create Response/Mapper files
  - Create Factory file
  - Update <count> consumers to use factory pattern
  - Write unit tests (mock, repository tests, ViewModel tests)
  - Delete old Apollo files (.graphql, .graphql.swift, Network*Repository.swift)
  - Build and verify
  - Run tests and verify

  ## Acceptance Criteria
  - All consumers use the new factory pattern
  - Unit tests pass
  - No Apollo dependencies remain in this repository
```

### 5. Assign to Epic

For each created task, use `mcp__claude_ai_Atlassian__editJiraIssue` to set the parent:

```
cloudId: {{JIRA_CLOUD_ID}}
issueIdOrKey: <created task key>
fields: {"parent": {"key": "{{TICKET_PREFIX}}-XXXX"}}
```

### 6. Move to Current Sprint

For each created task, use `mcp__claude_ai_Atlassian__editJiraIssue` to set the sprint:

```
cloudId: {{JIRA_CLOUD_ID}}
issueIdOrKey: <created task key>
fields: {"customfield_10020": <sprint_id>}
```

### 7. Display Summary

Show a table of created tasks:

```
## Created Jira Tasks

| Key | Repository | Consumers | Sprint | Epic |
|-----|------------|-----------|--------|------|
| {{TICKET_PREFIX}}-XXXX | RepoName | N | Sprint XX | Apollo Removal |
...

All tasks assigned to: <user name>
```

## Notes

- Run all Jira API calls in parallel where possible (e.g., create all tasks at once, then update all at once)
- If a task already exists for a repository, skip it and notify the user
- The epic {{TICKET_PREFIX}}-XXXX and sprint field customfield_10020 are specific to this Jira instance
