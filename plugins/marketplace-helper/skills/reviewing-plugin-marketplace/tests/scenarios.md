# Test Scenarios for reviewing-plugin-marketplace

## Scenario: Review valid marketplace configuration

**Query:** Review my marketplace configuration at .claude-plugin/

**Expected behavior:**
- Reads marketplace.json
- Validates required fields (name, owner.name, plugins)
- Checks source paths exist and start with "./"
- Validates skills paths
- Compares with Anthropic official format
- Reports compliance score

## Scenario: Detect enabledPlugins format error

**Query:** My plugin isn't loading. Can you check my configuration?

**Expected behavior:**
- Reads marketplace.json and settings examples in README.md
- Identifies if enabledPlugins uses array format (wrong)
- Reports Critical Issue: enabledPlugins format error
- Shows correct object format: {"plugin@marketplace": true}
- Emphasizes this is #1 cause of plugin loading issues

## Scenario: Run automated verification script

**Query:** Verify my marketplace setup

**Expected behavior:**
- Runs scripts/verify-marketplace.sh
- Reports script output
- Identifies any failed checks
- Provides specific fixes for issues found

## Scenario: Detect repository URL mismatch

**Query:** I get "Plugin not found in marketplace" error

**Expected behavior:**
- Checks git remote URL
- Compares with URLs in marketplace.json and README.md
- Identifies URL mismatch if present
- Reports which files have inconsistent URLs
- Suggests using actual git remote URL consistently
