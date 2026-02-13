While Snowflake Cortex Code is now generally available, DCM Projects are still in preview.

These Cortex Code Skills for DCM Projects are part of this DCM preview.

---

## Overview

The DCM skill guides Cortex Code through Database Change Management workflows. It provides structured step-by-step guidance, safety guardrails (like requiring confirmation before deployments), and loads reference documentation about DCM syntax and CLI commands—so you can work with DCM without memorizing the details.

## Benefits

- **No need to memorize syntax**: The skill knows DCM's DEFINE syntax, manifest.yml structure, and CLI commands
- **Built-in safety checks**: Always runs plan before deploy, highlights destructive operations, requires explicit confirmation
- **Guided workflows**: Asks clarifying questions before writing code, proposes changes for approval
- **Handles the details**: Parses analyze/plan output files, tracks dependencies, suggests deployment aliases


## Setup

You can add this DCM skill to your Cortex Code CLI by cloning this repository and referencing this path.

1. Make sure you have cortex code installed
https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code-cli

2. Once you run `cortex` in your terminal, you can run  `/skill add path>` to add this repository with the DCM skills

3. start asking CoCo to build, extend, describe, optimize or migrate DCM Projects
   


## What It Can Do

- Create new DCM projects with proper structure (manifest.yml, definitions folder)
- Modify existing projects—including downloading sources from deployed projects
- Validate projects and explain dependencies/lineage
- Guide you through safe deployments with clear summaries of what will change
- Set up data quality expectations with Data Metric Functions

## Example Prompts

```
Create a new DCM project for managing my analytics pipeline
```

```
I have a DCM project deployed to PROD_DB.PROJECTS.MY_PROJECT - download the sources and add a new table
```

```
Analyze my DCM project and show me what depends on the CUSTOMERS table
```

```
Deploy my DCM project to the DEV configuration
```

```
Add a data quality check to ensure ORDER_AMOUNT is never null
```
