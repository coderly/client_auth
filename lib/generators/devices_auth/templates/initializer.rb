DevicesAuth.setup do |config|
  #the model to be used as the resource that will login through the devices
  config.devices_owner_model = :user
  #the key to identify the resource that will add devices
  config.devices_owner_key = :token
end