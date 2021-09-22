Function New-FloppyDiskImage {
    Param(
        [Parameter(Mandatory=$true)]
        [String]$OutputPath
    )

    $SectorSize = 512
    $NumberOfSectors = 2880

    [Byte[]]$OutputBytes = [Byte[]]::new($SectorSize*$NumberOfSectors)

    [Byte[]]$BootSector = [Byte[]]::new($SectorSize)

    $BiosParameterBlock = [System.Collections.ArrayList]::new()

    [Byte[]]$OEMLabel = [System.Text.Encoding]::ASCII.GetBytes("DEFAULT ")
    $BiosParameterBlock.Add($OEMLabel) | Out-Null

    [Byte[]]$BytesPerSector = [Byte[]]@(0x00, 0x02)
    $BiosParameterBlock.Add($BytesPerSector) | Out-Null

    [Byte[]]$SectorsPerCluster = [Byte[]]@(0x01)
    $BiosParameterBlock.Add($SectorsPerCluster) | Out-Null

    [Byte[]]$ReservedSectorsForBoot = [Byte[]]@(0x01, 0x00)
    $BiosParameterBlock.Add($ReservedSectorsForBoot) | Out-Null

    [Byte[]]$NumberOfFATs = [Byte[]]@(0x02)
    $BiosParameterBlock.Add($NumberOfFATs) | Out-Null

    [Byte[]]$NumberOfRootDirEntries = [Byte[]]@(0xE0, 0x00) # (14 Sectors * 512 Bytes/Sector) / 32 Bytes Per Entry
    $BiosParameterBlock.Add($NumberOfRootDirEntries) | Out-Null

    [Byte[]]$LogicalSectors = [Byte[]]@(0x40, 0x0B) # 2880 Sectors
    $BiosParameterBlock.Add($LogicalSectors) | Out-Null

    [Byte[]]$MediaDescriptor = [Byte[]]@(0xF0) # 0xF0 for floppy disk
    $BiosParameterBlock.Add($MediaDescriptor) | Out-Null

    [Byte[]]$SectorsPerFAT = [Byte[]]@(0x09, 0x00)
    $BiosParameterBlock.Add($SectorsPerFAT) | Out-Null

    [Byte[]]$SectorsPerTrack = [Byte[]]@(0x12, 0x00)
    $BiosParameterBlock.Add($SectorsPerTrack) | Out-Null

    [Byte[]]$Sides = [Byte[]]@(0x02, 0x00)
    $BiosParameterBlock.Add($Sides) | Out-Null

    [Byte[]]$HiddenSectors = [Byte[]]@(0x00)*4
    $BiosParameterBlock.Add($HiddenSectors) | Out-Null

    [Byte[]]$LogicalSectors = [Byte[]]@(0x00)*4
    $BiosParameterBlock.Add($LogicalSectors) | Out-Null

    [Byte[]]$DriveNumber = [Byte[]]@(0x00)
    $BiosParameterBlock.Add($DriveNumber) | Out-Null

    [Byte[]]$Reserved = [Byte[]]@(0x00)
    $BiosParameterBlock.Add($Reserved) | Out-Null

    [Byte[]]$BootSignature = [Byte[]]@(0x29)
    $BiosParameterBlock.Add($BootSignature) | Out-Null

    [Byte[]]$VolumeID = [Byte[]]@(0x00)*4
    $BiosParameterBlock.Add($VolumeID) | Out-Null

    [Byte[]]$VolumeLabel = [System.Text.Encoding]::ASCII.GetBytes("DEFAULT    ")
    $BiosParameterBlock.Add($VolumeLabel) | Out-Null

    [Byte[]]$FileSystem = [System.Text.Encoding]::ASCII.GetBytes("FAT12   ")
    $BiosParameterBlock.Add($FileSystem) | Out-Null

    $Offset = 3
    $BiosParameterBlock | ForEach {
        [System.Buffer]::BlockCopy($_, 0, $BootSector, $Offset, $_.Length)
        $Offset += $_.Length
    }

    $BootSector[510] = 0xAA
    $BootSector[511] = 0x55

    [System.Buffer]::BlockCopy($BootSector, 0, $OutputBytes, 0, 512)

    # FAT 1

    $OutputBytes[512] = 0xF0
    $OutputBytes[513] = 0xFF
    $OutputBytes[514] = 0xFF

    # FAT 2

    $OutputBytes[5120] = 0xF0
    $OutputBytes[5121] = 0xFF
    $OutputBytes[5122] = 0xFF

    [System.IO.File]::WriteAllBytes($OutputPath, $OutputBytes)
}
