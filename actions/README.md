# Snowflake DCM GitHub Actions

> **EXPERIMENTAL** -- These actions are provided as-is for evaluation purposes.
> They are not officially supported by Snowflake.
> Breaking changes may occur at any time.
> Use at your own risk.

A set of composable GitHub Actions for automating [Snowflake DCM Projects](https://docs.snowflake.com/en/user-guide/dcm-projects/dcm-projects-overview) pipelines. Each action handles one step of the lifecycle, and they can be combined to build end-to-end CI/CD workflows.

## Actions

| Action | Description |
|--------|-------------|
| [`dcm-connection-test`](#dcm-connection-test) | Test Snowflake connectivity, validate role match, check project status |
| [`dcm-plan`](#dcm-plan) | Run `snow dcm plan`, summarize the changeset, upload artifacts |
| [`dcm-deploy`](#dcm-deploy) | Deploy with optional drop detection, DT refresh, and expectation testing |

## Prerequisites

All actions require:

- **OIDC authentication** via `snowflakedb/snowflake-cli-action@v2.0` (handled internally)
- **GitHub Environment** matching the DCM target name (e.g. `DCM_STAGE`, `DCM_PROD_US`)
- **Workflow permissions**:

```yaml
permissions:
  id-token: write
  contents: read
```

When using `comment-on-pr: "true"` on `dcm-plan` or `dcm-deploy`, also add:

```yaml
permissions:
  id-token: write
  contents: read
  pull-requests: write
```

---

## dcm-connection-test

Tests the Snowflake connection for a target, validates that the connection role matches the manifest `project_owner`, and checks whether the DCM project already exists.

```yaml
- uses: Snowflake-Labs/snowflake_dcm_projects/actions/dcm-connection-test@v1
  with:
    target: DCM_STAGE
    project-path: my-dcm-project/
```

### Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `target` | yes | DCM target name from `manifest.yml` |
| `project-path` | yes | Path to the DCM project directory |

### Outputs

| Output | Description |
|--------|-------------|
| `result` | `success` or `failure` |
| `connection-account` | Snowflake account from the connection test |
| `connection-role` | Role used by the connection |
| `project-exists` | `true` or `false` |

---

## dcm-plan

Runs `snow dcm plan` against a target, writes a changeset summary (CREATE / ALTER / DROP counts by object domain) to the GitHub Step Summary, and uploads the plan output as an artifact.

```yaml
- uses: Snowflake-Labs/snowflake_dcm_projects/actions/dcm-plan@v1
  with:
    target: DCM_STAGE
    project-path: my-dcm-project/
    comment-on-pr: "true"
```

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `target` | yes | | DCM target name from `manifest.yml` |
| `project-path` | yes | | Path to the DCM project directory |
| `create-if-not-exists` | no | `true` | Run `snow dcm create --if-not-exists` before planning |
| `comment-on-pr` | no | `false` | Post the plan summary as a comment on the associated PR |

### Outputs

| Output | Description |
|--------|-------------|
| `result` | `success` or `failure` |
| `plan-file` | Path to `plan_result.json` |
| `create-count` | Number of CREATE operations |
| `alter-count` | Number of ALTER operations |
| `drop-count` | Number of DROP operations |

---

## dcm-deploy

Deploys the DCM project to a target. Optionally checks for destructive DROP operations before deploying and can run dynamic table refresh + data quality expectation tests after deployment.

The `dcm-plan` action **must** run before this action in the same job -- it produces the `out/plan/plan_result.json` file used for drop detection.

```yaml
- uses: Snowflake-Labs/snowflake_dcm_projects/actions/dcm-deploy@v1
  with:
    target: DCM_STAGE
    project-path: my-dcm-project/
    allow-drops: "false"
    test-expectations: "true"
    comment-on-pr: "true"
```

### Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `target` | yes | | DCM target name from `manifest.yml` |
| `project-path` | yes | | Path to the DCM project directory |
| `allow-drops` | no | `false` | Set to `true` to skip destructive drop detection |
| `test-expectations` | no | `false` | Refresh dynamic tables and run `snow dcm test` after deploy |
| `comment-on-pr` | no | `false` | Post a deploy summary as a comment on the associated PR |

### Outputs

| Output | Description |
|--------|-------------|
| `deploy-result` | `success` or `failure` |
| `test-result` | `success`, `failure`, or `skipped` |

---

## Full Example Workflow

A complete STAGE + PROD pipeline with PR comments:

```yaml
name: DCM Deploy

on:
  push:
    branches: [main]
    paths: ['my-dcm-project/**']

jobs:
  # ---- STAGE ----
  stage:
    runs-on: ubuntu-latest
    environment: DCM_STAGE
    permissions:
      id-token: write
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - uses: Snowflake-Labs/snowflake_dcm_projects/actions/dcm-connection-test@v1
        with:
          target: DCM_STAGE
          project-path: my-dcm-project/

      - uses: Snowflake-Labs/snowflake_dcm_projects/actions/dcm-plan@v1
        with:
          target: DCM_STAGE
          project-path: my-dcm-project/
          comment-on-pr: "true"

      - uses: Snowflake-Labs/snowflake_dcm_projects/actions/dcm-deploy@v1
        with:
          target: DCM_STAGE
          project-path: my-dcm-project/
          test-expectations: "true"
          comment-on-pr: "true"

  # ---- PROD ----
  prod:
    needs: stage
    runs-on: ubuntu-latest
    environment: DCM_PROD_US
    permissions:
      id-token: write
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - uses: Snowflake-Labs/snowflake_dcm_projects/actions/dcm-plan@v1
        with:
          target: DCM_PROD_US
          project-path: my-dcm-project/
          comment-on-pr: "true"

      - uses: Snowflake-Labs/snowflake_dcm_projects/actions/dcm-deploy@v1
        with:
          target: DCM_PROD_US
          project-path: my-dcm-project/
          test-expectations: "true"
          comment-on-pr: "true"
```
