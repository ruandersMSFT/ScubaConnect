locals {
  kv_prefix    = "${var.resource_prefix}-kv-"
  kv_unique_id = substr(replace((var.create_app ? azuread_application.app[0].client_id : data.azuread_application.app[0].client_id), "-", ""), 0, 24 - length(local.kv_prefix))

  key_vault_network_acls = var.allowed_access_ips == null ? null : object({
    ip_rules = var.allowed_access_ips
  })
}

# Azure Key Vault to hold an app registration certificate
module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.0"

  enable_telemetry                = false
  location                        = var.resource_group.location
  resource_group_name             = var.resource_group.name
  contacts                        = var.contact_emails
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
  legacy_access_policies_enabled  = true
  legacy_access_policies = {
    app = {
      object_id = var.object_id
      certificate_permissions = [
        "Create",
        "Delete",
        "Recover",
        "Get",
        "GetIssuers",
        "Import",
        "List",
        "ListIssuers",
        "ManageContacts",
        "Purge",
        "Update",
      ]
      secret_permissions = [
        "Delete",
        "Get",
        "List",
        "Purge",
        "Recover",
        "Set",
      ]
    }
  }
  name                       = "${local.kv_prefix}${local.kv_unique_id}"
  network_acls               = local.key_vault_network_acls
  sku_name                   = var.key_vault_sku_name
  soft_delete_retention_days = var.key_vault_soft_delete_retention_days
  tenant_id                  = var.tenant_id
}

# note this requires terraform to be run regularly
resource "time_rotating" "cert_rotation" {
  rotation_days = var.certificate_rotation_period_days
}

# Generate the app registration certificate
resource "azurerm_key_vault_certificate" "cert" {
  # Name change forces recreating certificate
  name         = "${var.resource_prefix}-app-cert-${formatdate("YYYY-MM-DD", time_rotating.cert_rotation.rfc3339)}"
  key_vault_id = module.key_vault.resource_id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "EmailContacts"
      }

      trigger {
        days_before_expiry = 7
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # client and server authentication
      extended_key_usage = ["1.3.6.1.5.5.7.3.1", "1.3.6.1.5.5.7.3.2"]

      key_usage = [
        "digitalSignature",
        "keyEncipherment",
      ]

      subject = "CN=${var.app_name}"
      # min 1 month; approx. twice length of rotation period
      validity_in_months = max(1, ceil(var.certificate_rotation_period_days * 2 / 30))
    }
  }
}

// note: if terraform isn't creating the app, a user must manually add the cert to the app
resource "azuread_application_certificate" "app_cert" {
  count          = var.create_app ? 1 : 0
  application_id = var.create_app ? azuread_application.app[0].id : data.azuread_application.app[0].id
  type           = "AsymmetricX509Cert"
  encoding       = "hex"
  value          = azurerm_key_vault_certificate.cert.certificate_data
  end_date       = azurerm_key_vault_certificate.cert.certificate_attribute[0].expires
  start_date     = azurerm_key_vault_certificate.cert.certificate_attribute[0].not_before
}

data "azurerm_key_vault_certificate_data" "scuba_cert_data" {
  name         = azurerm_key_vault_certificate.cert.name
  key_vault_id = module.key_vault.resource_id
}

# Write the cert to a file if it needs to be manually added to the app
resource "local_file" "scuba_pem_file" {
  content  = data.azurerm_key_vault_certificate_data.scuba_cert_data.pem
  filename = "${path.cwd}/${var.app_name}.pem"
}

data "azurerm_key_vault_secret" "pfx_b64" {
  name         = azurerm_key_vault_certificate.cert.name
  key_vault_id = module.key_vault.resource_id
}
