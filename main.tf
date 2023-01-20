resource "random_pet" "rg_name" {
  prefix = join("-", [var.resource_group_name_prefix, count.index])
  count  = 10
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name[count.index].id
  count    = 10
}
