$key = "D:\bjoer\OneDrive\Bjoern\Source\family-brain\.ssh\id_ed25519"
$host = "root@family-brain.boder.de"

ssh -i $key $host "docker ps --filter name=caddy --format 'Name: {{.Names}}  Status: {{.Status}}  Ports: {{.Ports}}'"
