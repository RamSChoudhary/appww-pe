application_gateways = {
  agw1_az1 = {
    resource_group_key = "rg_region1"
    name               = "app_gateway_example"
    vnet_key           = "vnet_region1"
    subnet_key         = "app_gateway_private"
    sku_name           = "Standard_v2"
    sku_tier           = "Standard_v2"
    capacity = {
      autoscale = {
        minimum_scale_unit = 0
        maximum_scale_unit = 10
      }
    }
    zones        = ["1"]
    enable_http2 = true

    identity = {
      managed_identity_keys = [
        "apgw_keyvault_secrets"
      ]
    }

    front_end_ip_configurations = {
      public = {
        name          = "public"
        public_ip_key = "example_agw_pip1_rg1"
        subnet_key    = "app_gateway_public"
      }
      private = {
        name                          = "private"
        vnet_key                      = "vnet_region1"
        subnet_key                    = "app_gateway_private"
        subnet_cidr_index             = 0 # It is possible to have more than one cidr block per subnet
        private_ip_offset             = 4 # e.g. cidrhost(10.10.0.0/25,4) = 10.10.0.4 => AGW private IP address
        private_ip_address_allocation = "Static"
      }
    }

    front_end_ports = {
      80 = {
        name     = "http-80"
        port     = 80
        protocol = "Http"
      }
      443 = {
        name     = "https-443"
        port     = 443
        protocol = "Https"
      }
      4431 = {
        name     = "https-4431"
        port     = 4431
        protocol = "Https"
      }
    }

    redirect_configurations = {
      redirect-https = {
        name                 = "redirect-https"
        redirect_type        = "Permanent"
        target_listener_name = "demoapp1-443-private"
        # target_url           = ""
        include_path         = true
        include_query_string = false
      }
    }
  }
}


application_gateway_applications = {
  demo_app1_az1_agw1 = {
    name                    = "demoapp1"
    application_gateway_key = "agw1_az1"

    listeners = {
      private_ssl = {
        name                           = "demoapp1-443-private"
        front_end_ip_configuration_key = "private"
        front_end_port_key             = "443"
        host_name                      = "demoapp1.cafdemo.com"
        request_routing_rule_key       = "default1"
        keyvault_certificate = {
          certificate_key = "demoapp1.cafdemo.com"
          // To use manual uploaded cert
          # certificate_name = "testkhairi"
          # keyvault_key     = "certificates"
          #  keyvault_id     = "/subscriptions/97958dac-xxxx-xxxx-xxxx-9f436fa73bd4/resourceGroups/jmtv-rg-example-app-gateway-re1/providers/Microsoft.KeyVault/vaults/jmtv-kv-certs"
        }
      }
      public_ssl = {
        name                           = "demoapp1-4431-public"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "4431"
        host_name                      = "demoapp1.cafdemo.com"
        request_routing_rule_key       = "default2"
        keyvault_certificate = {
          certificate_key = "demoapp1.cafdemo.com"
          // To use manual uploaded cert
          # certificate_name = "testkhairi"
          # keyvault_id     = "/subscriptions/97958dac-xxxx-xxxx-xxxx-9f436fa73bd4/resourceGroups/jmtv-rg-example-app-gateway-re1/providers/Microsoft.KeyVault/vaults/jmtv-kv-certs"
        }
      }
    }

    request_routing_rules = {
      default1 = {
        rule_type = "Basic"
        priority  = 10
      }
      default2 = {
        rule_type = "Basic"
        priority  = 11
      }
    }

    backend_http_setting = {
      port                                = 443
      protocol                            = "Https"
      pick_host_name_from_backend_address = true
    }

    backend_pool = {
      fqdns = [
        "cafdemo.appserviceenvironment.net"
      ]
    }

  }

  redirect-https = {
    name                    = "redirect-https"
    type                    = "redirect"
    application_gateway_key = "agw1_az1"

    listeners = {
      private = {
        name                           = "demoapp1-80-private"
        front_end_ip_configuration_key = "private"
        front_end_port_key             = "80"
        host_name                      = "demoapp1.cafdemo.com"
        request_routing_rule_key       = "default"
      }
    }

    request_routing_rules = {
      default = {
        rule_type                   = "Basic"
        redirect_configuration_name = "redirect-https"
        priority                    = 20
      }
    }
  }
}


keyvault_certificates = {
  "demoapp1.cafdemo.com" = {

    keyvault_key = "certificates"

    # may only contain alphanumeric characters and dashes
    name = "demoapp1-cafdemo-com"

    subject            = "CN=demoapp1"
    validity_in_months = 12

    subject_alternative_names = {
      #  A list of alternative DNS names (FQDNs) identified by the Certificate.
      # Changing this forces a new resource to be created.
      dns_names = [
        "demoapp1.cafdemo.com"
      ]

      # A list of email addresses identified by this Certificate.
      # Changing this forces a new resource to be created.
      # emails = []

      # A list of User Principal Names identified by the Certificate.
      # Changing this forces a new resource to be created.
      # upns = []
    }

    tags = {
      type = "SelfSigned"
    }

    # Possible values include Self (for self-signed certificate),
    # or Unknown (for a certificate issuing authority like Let's Encrypt
    # and Azure direct supported ones).
    # Changing this forces a new resource to be created
    issuer_parameters = "Self"

    exportable = true

    # Possible values include 2048 and 4096.
    # Changing this forces a new resource to be created.
    key_size  = 4096
    key_type  = "RSA"
    reuse_key = true

    # The Type of action to be performed when the lifetime trigger is triggered.
    # Possible values include AutoRenew and EmailContacts.
    # Changing this forces a new resource to be created.
    action_type = "AutoRenew"

    # The number of days before the Certificate expires that the action
    # associated with this Trigger should run.
    # Changing this forces a new resource to be created.
    # Conflicts with lifetime_percentage
    days_before_expiry = 30


    # The percentage at which during the Certificates Lifetime the action
    # associated with this Trigger should run.
    # Changing this forces a new resource to be created.
    # Conflicts with days_before_expiry
    # lifetime_percentage = 90

    # The Content-Type of the Certificate, such as application/x-pkcs12 for a PFX
    # or application/x-pem-file for a PEM.
    # Changing this forces a new resource to be created.
    content_type = "application/x-pkcs12"

    # A list of uses associated with this Key.
    # Possible values include
    # cRLSign, dataEncipherment, decipherOnly,
    # digitalSignature, encipherOnly, keyAgreement, keyCertSign,
    # keyEncipherment and nonRepudiation
    # and are case-sensitive.
    # Changing this forces a new resource to be created
    key_usage = [
      "cRLSign",
      "dataEncipherment",
      "digitalSignature",
      "keyAgreement",
      "keyCertSign",
      "keyEncipherment",
    ]
  }
}



global_settings = {
  default_region = "region1"
  regions = {
    region1 = "australiaeast"
  }
}

resource_groups = {
  rg_region1 = {
    name = "example-app-gateway-re1"
  }
}


keyvaults = {
  certificates = {
    name               = "certs"
    resource_group_key = "rg_region1"
    sku_name           = "standard"

    enabled_for_deployment = true

    creation_policies = {
      logged_in_user = {
        certificate_permissions = ["Get", "List", "Update", "Create", "Import", "Delete", "Purge", "Recover"]
        secret_permissions      = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
      }
    }
  }
}

keyvault_access_policies = {
  certificates = {
    apgw_keyvault_secrets = {
      managed_identity_key    = "apgw_keyvault_secrets"
      certificate_permissions = ["Get"]
      secret_permissions      = ["Get"]
    }
  }
}


managed_identities = {
  apgw_keyvault_secrets = {
    name               = "agw-secrets-msi"
    resource_group_key = "rg_region1"
  }
}


#
# Definition of the networking security groups
#
network_security_group_definition = {
  # This entry is applied to all subnets with no NSG defined
  empty_nsg = {
    nsg = []
  }

  application_gateway = {

    nsg = [
      {
        name                       = "Inbound-HTTP",
        priority                   = "120"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "80-82"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "Inbound-HTTPs",
        priority                   = "130"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "Inbound-AGW",
        priority                   = "140"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "65200-65535"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    ]
  }

  application_gateway_public_ingress = {

    nsg = [
      {
        name                       = "Inbound-HTTPs",
        priority                   = "130"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
    ]
  }
}

public_ip_addresses = {
  example_agw_pip1_rg1 = {
    name                    = "example_agw_pip1"
    resource_group_key      = "rg_region1"
    sku                     = "Standard"
    allocation_method       = "Static"
    ip_version              = "IPv4"
    zones                   = ["1"]
    idle_timeout_in_minutes = "4"

  }
}

vnets = {
  vnet_region1 = {
    resource_group_key = "rg_region1"
    vnet = {
      name          = "app_gateway"
      address_space = ["10.100.100.0/24"]
    }
    specialsubnets = {}
    subnets = {
      app_gateway_private = {
        name    = "app_gateway-private"
        cidr    = ["10.100.100.0/25"]
        nsg_key = "application_gateway"
      }
      app_gateway_public = {
        name    = "app_gateway-public"
        cidr    = ["10.100.100.1/25"]
        nsg_key = "application_gateway_public_ingress"
      }
    }

  }
}