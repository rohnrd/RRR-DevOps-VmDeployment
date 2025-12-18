# =============================================================================
# SSH Key Retrieval Script
# Run this after 'terraform apply' to get your SSH keys and connection info
# =============================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SSH Key Retrieval Tool" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if terraform state exists
if (-not (Test-Path "terraform.tfstate")) {
    Write-Host "ERROR: No terraform.tfstate found. Run 'terraform apply' first." -ForegroundColor Red
    exit 1
}

# Create keys directory if it doesn't exist
$keysDir = ".\ssh-keys"
if (-not (Test-Path $keysDir)) {
    New-Item -ItemType Directory -Path $keysDir | Out-Null
    Write-Host "Created directory: $keysDir" -ForegroundColor Green
}

# Get SSH keys from Terraform output
Write-Host "Retrieving SSH keys from Terraform state..." -ForegroundColor Yellow

try {
    # Get public key
    $publicKey = terraform output -raw ssh_public_key 2>$null
    
    # Get private key
    $privateKey = terraform output -raw ssh_private_key 2>$null
    
    # Get VM IPs
    $vmIps = terraform output -json vm_public_ips 2>$null | ConvertFrom-Json
    
    if ($publicKey -and $privateKey) {
        # Save private key
        $privateKeyPath = Join-Path $keysDir "id_rsa"
        $publicKeyPath = Join-Path $keysDir "id_rsa.pub"
        
        Set-Content -Path $privateKeyPath -Value $privateKey -NoNewline
        Set-Content -Path $publicKeyPath -Value $publicKey -NoNewline
        
        Write-Host "`n✓ SSH keys saved successfully!" -ForegroundColor Green
        Write-Host "  Private key: $privateKeyPath" -ForegroundColor White
        Write-Host "  Public key:  $publicKeyPath" -ForegroundColor White
        
        # Display public key
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "PUBLIC SSH KEY:" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host $publicKey -ForegroundColor White
        
        # Save connection instructions
        $instructionsPath = Join-Path $keysDir "SSH_CONNECTION_INFO.txt"
        $instructions = @"
=============================================================================
SSH CONNECTION INFORMATION
=============================================================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

PUBLIC SSH KEY:
$publicKey

PRIVATE KEY LOCATION:
$privateKeyPath

"@

        if ($vmIps) {
            $instructions += @"

VM CONNECTION DETAILS:
----------------------------------------

"@
            $vmIndex = 1
            foreach ($ip in $vmIps) {
                if ($ip) {
                    $instructions += @"
VM $vmIndex (Linux):
  IP Address: $ip
  Username: azureuser
  
  Connection Command (Windows):
    ssh -i "$privateKeyPath" azureuser@$ip
  
  Connection Command (Linux/Mac):
    chmod 600 "$privateKeyPath"
    ssh -i "$privateKeyPath" azureuser@$ip

"@
                }
                $vmIndex++
            }
        }

        $instructions += @"

IMPORTANT NOTES:
----------------------------------------
1. Keep the private key secure - do not share it
2. The private key is also stored in Terraform state (sensitive)
3. On Linux/Mac, you must set proper permissions: chmod 600 id_rsa
4. Windows users can use this key directly with OpenSSH or PuTTY (convert to .ppk)

FOR PUTTY USERS (Windows):
----------------------------------------
1. Download PuTTYgen from: https://www.putty.org/
2. Load the private key file: $privateKeyPath
3. Save as PuTTY Private Key (.ppk format)
4. Use the .ppk file in PuTTY for SSH connection

=============================================================================
"@

        Set-Content -Path $instructionsPath -Value $instructions
        
        # Display connection info
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "VM CONNECTION INFORMATION:" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        
        if ($vmIps) {
            $vmIndex = 1
            foreach ($ip in $vmIps) {
                if ($ip) {
                    Write-Host "`nVM $vmIndex (Linux VM):" -ForegroundColor Yellow
                    Write-Host "  IP: $ip" -ForegroundColor White
                    Write-Host "  SSH Command: ssh -i `"$privateKeyPath`" azureuser@$ip" -ForegroundColor Green
                }
                $vmIndex++
            }
        } else {
            Write-Host "No public IPs found. VMs may not have public IPs enabled." -ForegroundColor Yellow
        }
        
        Write-Host "`n✓ Complete connection information saved to:" -ForegroundColor Green
        Write-Host "  $instructionsPath" -ForegroundColor White
        
        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "QUICK ACTIONS:" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "1. View connection info: notepad `"$instructionsPath`"" -ForegroundColor White
        Write-Host "2. Copy public key:      Get-Content `"$publicKeyPath`" | Set-Clipboard" -ForegroundColor White
        Write-Host "3. Set permissions:      icacls `"$privateKeyPath`" /inheritance:r /grant:r `"`$($env:USERNAME):R`"" -ForegroundColor White
        
    } else {
        Write-Host "`nWARNING: SSH keys not found in Terraform output." -ForegroundColor Yellow
        Write-Host "This might mean:" -ForegroundColor Yellow
        Write-Host "  - Terraform apply hasn't been run yet" -ForegroundColor Yellow
        Write-Host "  - No Linux VMs are being deployed" -ForegroundColor Yellow
        Write-Host "  - The SSH key outputs are not defined in main.tf" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "`nERROR: Failed to retrieve SSH keys" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================`n" -ForegroundColor Cyan
