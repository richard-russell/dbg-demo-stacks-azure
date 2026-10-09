# Demo 3 (Azure) Walkthrough: Multiple Provider Instances per Deployment

This guide shows how **Terraform Stacks** handles a module that needs several Azure provider instances at once:
- one `azurerm` provider per landing zone subscription
- one shared `azurerm` provider for the network hub
- one shared `azuread` provider

This is the same pattern your existing workspace code already uses.

---

## Key Concept Being Demonstrated

**Multiple named Azure provider instances per deployment, mapped directly to your existing module pattern.**

Each landing zone subscription gets its **own identity** (`azurerm.lz`). The **network hub** (`azurerm.network`) and **Azure AD** (`azuread`) providers are shared across all landing zones. The modules don't change: they still declare `configuration_aliases = [azurerm.lz]` / `[azurerm.network]` exactly as in classic Terraform. Only the caller changes.

---

## Side-by-Side: Classic Terraform vs. Stacks

### Classic Terraform (workspace): your current pattern

Each landing zone needs its own explicitly named provider alias (`azurerm.lz1`, `azurerm.lz2`, `azurerm.lz3`) plus a module call that wires it in:

```hcl
module "lz1" {
  providers = {
    azurerm.lz      = azurerm.lz1
    azurerm.network = azurerm.network
    azuread         = azuread
  }
}
module "lz2" {
  providers = {
    azurerm.lz      = azurerm.lz2
    azurerm.network = azurerm.network
    azuread         = azuread
  }
}
module "lz3" {
  providers = {
    azurerm.lz      = azurerm.lz3
    azurerm.network = azurerm.network
    azuread         = azuread
  }
}
```

The module calls also need three separate `provider "azurerm" { alias = "lz1" ... }` / `lz2` / `lz3` blocks. Adding a fourth landing zone means a fourth alias block and a fourth module call. All three LZs also share **one state file**.

### Terraform Stacks: this repository

One `for_each` provider block replaces all the per-LZ aliases ([`providers.tfcomponent.hcl`](providers.tfcomponent.hcl:13)):

```hcl
# One provider instance per landing zone — keyed by lz_configs map key
provider "azurerm" "lz" {
  for_each = var.lz_configs

  config {
    features {}

    subscription_id = each.value.subscription_id
    tenant_id       = var.tenant_id
    client_id       = each.value.client_id
    use_oidc        = true
    oidc_token      = var.identity_token_lz
  }
}

provider "azurerm" "network" { ... }   # single shared instance
provider "azuread" "this"    { ... }   # single shared instance
```

One `for_each` component picks up the matching keyed provider ([`components.tfcomponent.hcl`](components.tfcomponent.hcl:2)):

```hcl
component "landing_zone" {
  for_each = var.lz_configs
  source   = "./modules/landing-zone"

  providers = {
    azurerm.lz = provider.azurerm.lz[each.key]
    azuread    = provider.azuread.this
  }
}

component "shared_network" {
  source = "./modules/shared-network"

  providers = {
    azurerm.network = provider.azurerm.network
  }
}
```

In classic Terraform, the shared network resources sit inside the LZ module call. Here they are their own `shared_network` component, so `azurerm.network` is passed to that component rather than to `landing_zone`.

Each deployment file passes a single-entry `lz_configs` map, so each deployment resolves to exactly one LZ provider instance ([`lz-01.tfdeploy.hcl`](lz-01.tfdeploy.hcl:1)):

```hcl
deployment "lz_01" {
  inputs = {
    lz_configs = {
      lz_01 = {
        subscription_id = local.lz_subscription_ids["lz_01"]
        client_id       = local.lz_client_ids["lz_01"]
        location        = "uksouth"
      }
    }
    ...
  }
}
```

| | Classic Terraform | Stacks |
|---|---|---|
| Per-LZ provider definitions | 3 explicit alias blocks (`lz1`, `lz2`, `lz3`) | 1 `for_each` provider block |
| Per-LZ module wiring | 3 module calls | 1 `for_each` component |
| Adding LZ #4 | New alias + new module call | New `lz-04.tfdeploy.hcl` file |
| State | 1 shared state | 1 isolated state per deployment |

---

## Live Demo Walkthrough

### Scenario A: Deployment-Level Change (Targeted Blast Radius)

**Action**: Change `extra_tags` for a single landing zone in [`lz-01.tfdeploy.hcl`](lz-01.tfdeploy.hcl:23):

```hcl
    extra_tags = merge(local.common_extra_tags, { Deployment = "lz-01", Environment = "dev", Updated = "true" })
```

Commit and push, or run `terraform stacks configuration upload`.

**Observation**:
- HCP Terraform evaluates the new configuration version.
- **Only deployment `lz_01` produces resource changes**: in-place tag updates on its resource group, Key Vault and secrets, plus the `lz_01` shared network resource group.
- `lz_02` and `lz_03` have unchanged inputs, so they plan with zero changes.
- `lz_01` belongs to the `dev` group and the plan deletes nothing, so `deployment_auto_approve "safe_changes"` approves it automatically.

---

### Scenario B: Component-Level Change (Coordinated Rollout)

**Action**: Change the shared module in `modules/landing-zone/main.tf`. For example, add a tag to `local.common_tags`:

```hcl
locals {
  common_tags = merge(
    {
      Name        = lower(var.name)
      Environment = var.environment
      ManagedBy   = "Terraform"
      CostCenter  = "platform"
    },
    var.extra_tags
  )
}
```

Or add a new Key Vault secret:

```hcl
resource "azurerm_key_vault_secret" "owner" {
  provider = azurerm.lz

  name         = "owner"
  value        = "platform-team"
  key_vault_id = azurerm_key_vault.lz.id

  tags = local.common_tags

  depends_on = [azurerm_key_vault_access_policy.deployer]
}
```

**Observation**:
- A single push or upload triggers plans for **all 3 LZ deployments in parallel**.
- Each deployment applies the change through **its own** `azurerm.lz[...]` provider instance, so each change lands in the correct subscription under the correct identity.
- No scripting or per-workspace triggering is needed to roll out a fleet-wide change.
- All 3 deployments are in the `dev` group and the change only adds or updates resources, so they auto-approve.

---

## How Credentials Work

```
identity_token "azurerm_lz"      ──► provider.azurerm.lz["lz_01"]   client_id = stacks-lz-01
  (one JWT per deployment)       ──► provider.azurerm.lz["lz_02"]   client_id = stacks-lz-02
                                 ──► provider.azurerm.lz["lz_03"]   client_id = stacks-lz-03

identity_token "azurerm_network" ──► provider.azurerm.network       client_id = stacks-network

identity_token "azuread"         ──► provider.azuread.this          client_id = stacks-azuread
```

- **3 `identity_token` blocks → 5 app registrations.** All three tokens use the same audience, `api://AzureADTokenExchange`.
- The **`client_id`** on each provider instance decides which app registration Entra ID exchanges the JWT against. That app registration's federated identity credential must trust the deployment's subject (`...:deployment:lz_01:operation:plan|apply`).
- `identity_token.azurerm_lz` serves 3 app registrations: the JWT is the same shape, but each `azurerm.lz[...]` instance presents a different `client_id`.
- **Only the JWT is ephemeral.** The `identity_token_*` variables are declared `ephemeral = true`, so they are never written to state or plan files. Client IDs, subscription IDs and the tenant ID are not secrets. They sit in plain `locals` in [`deployments.tfdeploy.hcl`](deployments.tfdeploy.hcl:22), and no client secrets exist anywhere.
- Least privilege by design: `stacks-lz-01` can only reach the `lz_01` subscription. A misconfiguration in one LZ cannot write into another LZ's subscription.

---

## Key Talking Points

1. **Stacks natively models your existing pattern.**
   You already run several subscriptions with several identities: per-LZ `azurerm`, shared network `azurerm`, shared `azuread`. Stacks expresses this directly, and the modules keep their `configuration_aliases` unchanged.

2. **`for_each` on providers removes the alias boilerplate.**
   You no longer define `azurerm.lz1` / `azurerm.lz2` / `azurerm.lz3` explicitly. One `provider "azurerm" "lz" { for_each = var.lz_configs }` block scales to any number of landing zones. Adding an LZ means adding one `.tfdeploy.hcl` file.

3. **Per-deployment state isolation.**
   Each deployment (`lz_01`, `lz_02`, `lz_03`) has its own state. If the `lz_02` Key Vault fails to create (for example, a name collision or a soft-deleted vault), `lz_01` and `lz_03` are unaffected and keep applying normally.

4. **The shared network component runs alongside the LZ components in the same coordinated plan.**
   `shared_network` and `landing_zone` are planned and applied together in every deployment. You don't need to sequence a separate network workspace or pass outputs between workspaces by hand.
