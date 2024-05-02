func allSizes() array => [
  {
    name: 'small'
    nrAppVms: 1
    nrMediaVms: 2
    sizeAppVm: 'Standard_D16_v5'
    sizeMediaVm: 'Standard_L8as_v3'
  }
  {
    name: 'medium'
    nrAppVms: 1
    nrMediaVms: 6
    sizeAppVm: 'Standard_D64_v5'
    sizeMediaVm: 'Standard_L8as_v3'
  }
  {
    name: 'large'
    nrAppVms: 1
    nrMediaVms: 12
    sizeAppVm: 'Standard_D64_v5'
    sizeMediaVm: 'Standard_L64s_v3'
  }
  {
    name: 'xlarge'
    nrAppVms: 1
    nrMediaVms: 24 
    sizeAppVm: 'Standard_D64_v5'
    sizeMediaVm: 'Standard_L64as_v3'
  }
]


@export()
func getSize( sizeInput string ) object => last(filter( allSizes(), size => size.name == sizeInput ))
