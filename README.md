# DBG Demo 3 (Azure): Terraform Stacks with Multiple Provider Instances

Azure Terraform Stacks demo showing **multiple named provider instances per deployment**: each landing zone gets its own `azurerm` identity, and every deployment shares one network provider and one Azure AD provider.

## Overview

This repository uses **Terraform Stacks** (GA syntax: `.tfcomponent.hcl` and `.tfdeploy.hcl`) to manage 3 Azure landing zones as separate deployments within a single Stack in HCP Terraform.

It mirrors a common classic Terraform pattern. In that pattern, a module receives several provider aliases (`azurerm.lz`, `azurerm.network`, `azuread`), and the caller writes one explicit alias per landing zone. In Stacks, `for_each` on the `provider` block replaces those per-LZ alias blocks.

### Architecture

- **Providers (`providers.tfcomponent.hcl`)**:
  - `provider "azurerm" "lz"` with `for_each = var.lz_configs` creates one instance per landing zone, each with its own subscription and client ID.
  - `provider "azurerm" "network"` is a single shared instance for the network hub subscription.
  - `provider "azuread" "this"` is a single shared Azure AD instance.
- **Components (`components.tfcomponent.hcl`)**:
  - `component "landing_zone"` uses `for_each = var.lz_configs` and maps `azurerm.lz = provider.azurerm.lz[each.key]` and `azuread = provider.azuread.this`.
  - `component "shared_network"` maps `azurerm.network = provider.azurerm.network`.
- **Deployments (`.tfdeploy.hcl`)**: 3 deployments (`lz_01`, `lz_02`, `lz_03`). Each passes a single-entry `lz_configs` map, so the `for_each` provider and component resolve to exactly one instance per deployment.
- **Deployment Groups & Auto-Approval**:
  - `dev`: auto-approves plans that apply cleanly and delete nothing (`deployment_auto_approve "safe_changes"`).
  - `prod`: requires manual approval. No deployments use it yet.

### Provider Topology (per deployment)

```
deployment "lz_01"
  azurerm.lz      → provider.azurerm.lz["lz_01"]   (client_id = local.lz_client_ids["lz_01"])
  azurerm.network → provider.azurerm.network       (client_id = local.network_client_id)
  azuread         → provider.azuread.this          (client_id = local.azuread_client_id)
```

## Identity Setup: 5 App Registrations, 3 Identity Tokens

Authentication uses HCP Terraform workload identity (OIDC) with Entra ID **federated identity credentials (FICs)**. No client secrets are stored anywhere.

App registration names below are examples.

| # | App Registration | Used by provider | Identity token | Client ID source |
|---|---|---|---|---|
| 1 | `stacks-lz-01` | `provider.azurerm.lz["lz_01"]` | `identity_token.azurerm_lz` | `local.lz_client_ids["lz_01"]` |
| 2 | `stacks-lz-02` | `provider.azurerm.lz["lz_02"]` | `identity_token.azurerm_lz` | `local.lz_client_ids["lz_02"]` |
| 3 | `stacks-lz-03` | `provider.azurerm.lz["lz_03"]` | `identity_token.azurerm_lz` | `local.lz_client_ids["lz_03"]` |
| 4 | `stacks-network` | `provider.azurerm.network` | `identity_token.azurerm_network` | `local.network_client_id` |
| 5 | `stacks-azuread` | `provider.azuread.this` | `identity_token.azuread` | `local.azuread_client_id` |

How the 3 `identity_token` blocks map to the 5 app registrations:

- All 3 `identity_token` blocks in `deployments.tfdeploy.hcl` use the Azure audience `api://AzureADTokenExchange`.
- The **client ID** passed to each provider instance decides which app registration the JWT is exchanged against. For example, `identity_token.azurerm_lz` serves 3 app registrations because each `azurerm.lz[...]` instance has a different `client_id`.
- The JWT is the only ephemeral or sensitive value. Client IDs, subscription IDs and the tenant ID are identifiers, not secrets, so they live in `locals`.

### Federated Identity Credentials

Each app registration needs an FIC per deployment and operation that uses it. The HCP Terraform Stacks token subject has this format:

```
organization:<ORG>:project:<PROJECT>:stack:<STACK>:deployment:<DEPLOYMENT>:operation:<plan|apply>
```

| App Registration | Deployments to trust | FICs (plan + apply) |
|---|---|---|
| `stacks-lz-01` | `lz_01` | 2 |
| `stacks-lz-02` | `lz_02` | 2 |
| `stacks-lz-03` | `lz_03` | 2 |
| `stacks-network` | `lz_01`, `lz_02`, `lz_03` | 6 |
| `stacks-azuread` | `lz_01`, `lz_02`, `lz_03` | 6 |

FIC settings: issuer `https://app.terraform.io`, audience `api://AzureADTokenExchange`.

Role assignments (least privilege):
- `stacks-lz-0N`: `Contributor` on its own LZ subscription only.
- `stacks-network`: `Contributor` on the network hub subscription only.
- `stacks-azuread`: Microsoft Graph application permissions only for any Azure AD resources you add. The current modules create none, so it needs no Graph permissions yet.

After creating the app registrations, replace the placeholder GUIDs in the `locals` block of `deployments.tfdeploy.hcl`.

## Repository Structure

```
dbg-demo-stacks-azure/
├── .terraform-version          # Pinned Terraform version (1.14.5)
├── variables.tfcomponent.hcl   # Stack variables (ephemeral identity tokens, lz_configs, client IDs)
├── providers.tfcomponent.hcl   # azurerm.lz (for_each), azurerm.network, azuread.this
├── components.tfcomponent.hcl  # landing_zone (for_each) + shared_network components
├── outputs.tfcomponent.hcl     # LZ resource group / Key Vault names, shared network RG name
├── deployments.tfdeploy.hcl    # identity_token blocks, locals, auto-approve, deployment groups
├── lz-01.tfdeploy.hcl          # Deployment block for lz_01
├── lz-02.tfdeploy.hcl          # Deployment block for lz_02
├── lz-03.tfdeploy.hcl          # Deployment block for lz_03
├── modules/
│   ├── landing-zone/           # Resource group + Key Vault + access policy + 2 secrets (azurerm.lz)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── shared-network/         # Shared hub resource group (azurerm.network)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── DEMO.md                     # Live demo script & talking points
└── README.md                   # This file
```

## CLI Usage

```bash
# Initialize and validate stack configuration
terraform stacks init
terraform stacks validate

# Upload stack configuration (triggers deployment runs in HCP Terraform)
terraform stacks configuration upload

# List and monitor deployment runs
terraform stacks deployment-run list
terraform stacks deployment-group watch -deployment-group=dev
```
