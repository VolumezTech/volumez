func allSizes() object => {
  small: {
    nrAppVms: 1
    nrMediaVms: 2
    sizeAppVm: 'Standard_D16_v5'
    sizeMediaVm: 'Standard_L8as_v3'
  }
  medium: {
    nrAppVms: 1
    nrMediaVms: 6
    sizeAppVm: 'Standard_D64_v5'
    sizeMediaVm: 'Standard_L8as_v3'
  }
  large: {
    nrAppVms: 1
    nrMediaVms: 12
    sizeAppVm: 'Standard_D64_v5'
    sizeMediaVm: 'Standard_L64s_v3'
  }
  xlarge: {
    nrAppVms: 1
    nrMediaVms: 24 
    sizeAppVm: 'Standard_D64_v5'
    sizeMediaVm: 'Standard_L64as_v3'
  }
} 


@export()
func getSize( sizeInput string ) object => allSizes().sizeInput
