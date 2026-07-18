# Network Setup Guide — NFP Fleet

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SPECTRUM SBE1V1K ROUTER                       │
│                        (WiFi 7, "Lanji Vimsmoke")                    │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────────────────────┐   │
│  │ DHCP: ON │  │ DNS → luffy   │  │ Port Forward → luffy         │   │
│  │ (default)│  │ 192.168.1.54  │  │ 51820, 9993, 8086, 21115-19 │   │
│  └──────────┘  └──────────────┘  └──────────────────────────────┘   │
│                       │                                              │
│    WiFi 7 ────────────┼──────────────────────┐                       │
│                       │                      │                       │
└───────────────────────┼──────────────────────┼───────────────────────┘
                        │                      │
              ┌─────────▼──────────┐  ┌───────▼────────┐
              │  luffy (.54)       │  │  z0r0 (.39)    │
              │  AdGuard DNS :53   │  │  Tailscale     │
              │  AdGuard Web :3002 │  │  WireGuard     │
              │  Headscale :8086   │  │  ZeroTier      │
              │  WireGuard ctrl    │  │  RustDesk      │
              │  ZeroTier ctrl     │  └────────────────┘
              │  RustDesk server   │
              │  Caddy RP          │
              │  VPN NAT/forward   │
              └────────────────────┘
                        ▲
                        │ VPN mesh (Tailscale/Headscale)
          ┌─────────────┼─────────────────────────┐
          │             │                           │
   ┌──────┴──────┐  ┌───┴────────┐  ┌──────────────┴───────┐
   │ Android     │  │ Windows    │  │ Friend's Desktop     │
   │ Tailscale   │  │ Laptop     │  │ Windows + RTX 5090   │
   │ RustDesk    │  │ Tailscale  │  │ Tailscale             │
   │             │  │ RustDesk   │  │ RustDesk + Sunshine   │
   │             │  │ Hermes     │  │ Ollama/vLLM           │
   └─────────────┘  └────────────┘  └──────────────────────┘
```

## Phase 1: Spectrum Router Configuration

Log into the Spectrum SBE1V1K router admin panel (typically `192.168.1.1`).

### 1.1 — IP Reservation for Luffy

Reserve `192.168.1.54` for luffy's MAC address so it always gets the same IP.

1. Find luffy's MAC: `ip link show` on luffy, look for the Ethernet interface
2. In router admin: **LAN → DHCP → IP Reservation / Address Reservation**
3. Add entry: MAC `xx:xx:xx:xx:xx:xx` → IP `192.168.1.54`
4. Also reserve z0r0: MAC → `192.168.1.39`

### 1.2 — Set DNS to AdGuard

Point the router's DNS to luffy's AdGuard Home so **all WiFi/LAN devices get ad blocking automatically**.

1. In router admin: **LAN → DHCP → DNS Settings** (or **WAN → DNS**)
2. Set Primary DNS: `192.168.1.54`
3. Set Secondary DNS: `9.9.9.9` (Quad9 fallback, in case luffy is down)
4. Save and reboot router (or renew DHCP leases on devices)

> **Verify**: After applying, any device on WiFi should get `192.168.1.54` as DNS.
> Test: `nslookup doubleclick.net` should return `0.0.0.0` (blocked by AdGuard).

### 1.3 — Port Forwarding

Forward these ports to luffy (`192.168.1.54`) for remote VPN access:

| Port | Protocol | Service | Purpose |
|------|----------|---------|---------|
| 51820 | UDP | WireGuard | Direct VPN from z0r0/peers |
| 9993 | UDP | ZeroTier | ZeroTier mesh |
| 8086 | TCP | Headscale | Tailscale control server |
| 21115 | TCP | RustDesk hbbs | NAT test |
| 21116 | TCP+UDP | RustDesk hbbs | ID registration |
| 21117 | TCP | RustDesk hbbr | Relay |
| 21118 | TCP | RustDesk web | Web client (hbbs) |
| 21119 | TCP | RustDesk web | Web client (hbbr) |
| 80 | TCP | Caddy | HTTP (for ACME challenges) |
| 443 | TCP+UDP | Caddy | HTTPS + HTTP/3 |

1. In router admin: **WAN → Port Forwarding** (or **NAT → Virtual Server**)
2. Add each port above, forwarding to `192.168.1.54`
3. For TCP+UDP ports (21116, 443), create two separate rules

### 1.4 — WiFi 7 (Optional)

The SBE1V1K supports WiFi 7. Ensure it's enabled:
1. In router admin: **WiFi → Advanced → WiFi 7 / 802.11be**
2. Enable if not already on
3. Use WPA3 or WPA2/WPA3 mixed mode
4. Set a strong password

> **Note**: Your devices need WiFi 6 (802.11ax) or WiFi 7 (802.11be) support to benefit.
> z0r0 (LG 17Z90Q, Intel AX211) supports WiFi 6E. Most 2024+ phones support WiFi 6/7.

---

## Phase 2: Deploy NixOS Changes

After the router is configured, deploy the flake changes:

```bash
# Build and deploy both machines
cd ~/Clan/NFP
clan machines update luffy
clan machines update z0r0
```

### What changed on luffy:
- AdGuard Home enabled (DNS sinkhole on :53, web UI on :3002)
- VPN gateway (IP forwarding + NAT for VPN exit traffic)
- WireGuard controller (Clan module, port 51820)
- ZeroTier controller (Clan module, port 9993)
- Headscale DNS now points to local AdGuard
- Firewall ports opened for all VPN + DNS + RustDesk

### What changed on z0r0:
- AdGuard Home disabled (moved to luffy)
- WireGuard peer (connects to luffy as controller)
- ZeroTier peer (connects to luffy as controller)
- Firewall ports opened for VPN interfaces

---

## Phase 3: Device Setup

### 3.1 — Android Phone

1. **Tailscale** (VPN + mesh):
   - Install Tailscale from Play Store
   - Open app → Settings → Use custom server
   - Enter: `https://headscale.lovelain.duckdns.org`
   - Sign in and authorize on luffy: `headscale user create phone`
   - Or if open membership: `headscale users create phone`

2. **RustDesk** (remote desktop):
   - Install RustDesk from Play Store
   - Settings → ID/Relay Server
   - ID Server: `192.168.1.54` (LAN) or luffy's Tailscale IP (remote)
   - Relay Server: `192.168.1.54`
   - API Server: (leave blank)

### 3.2 — Windows Laptop

1. **Tailscale** (VPN + mesh):
   - Install Tailscale from https://tailscale.com/download
   - Open app → Settings → Use custom server
   - Enter: `https://headscale.lovelain.duckdns.org`
   - Sign in and authorize on luffy

2. **RustDesk** (remote desktop):
   - Install from https://rustdesk.com
   - Settings → Network → ID/Relay Server
   - ID Server: `192.168.1.54` or luffy's Tailscale IP
   - Relay Server: `192.168.1.54`

3. **Hermes Agent** (for Chimera tool automation):
   - Install NixOS WSL: `wsl --install -d NixOS` (or use NixOS WSL flake)
   - Configure Hermes in WSL to control Chimera tool
   - USB forwarding from VPS via usbipd-win or similar

4. **Chimera Tool**:
   - Runs natively on Windows (not in WSL)
   - Hermes in WSL can launch it via Windows commands

### 3.3 — Friend's Desktop (Windows + RTX 5090)

1. **Tailscale** (VPN + mesh):
   - Install Tailscale
   - Use custom server: `https://headscale.lovelain.duckdns.org`
   - Authorize on luffy

2. **RustDesk** (remote desktop):
   - Install RustDesk
   - Point to luffy's relay

3. **Sunshine** (game streaming for Cyberpunk 2077 etc):
   - Install Sunshine from https://github.com/LizardByte/Sunshine
   - Configure as host
   - On z0r0, install Moonlight client
   - Connect over Tailscale IP

4. **AI Workloads** (Ollama/vLLM):
   - Install Ollama for Windows or vLLM
   - Bind to Tailscale IP so it's accessible from z0r0
   - Example: `OLLAMA_HOST=100.x.x.x ollama serve`
   - From z0r0: `OLLAMA_HOST=100.x.x.x:11434 ollama run llama3.3`

---

## Phase 4: Verify

After everything is deployed and devices connected:

```bash
# On any device, verify DNS is going through AdGuard
nslookup doubleclick.net
# Should return 0.0.0.0 (blocked)

# Verify VPN mesh
tailscale status  # or: headscale node list on luffy

# Verify WireGuard (on z0r0)
wg show

# Verify ZeroTier (on luffy)
zerotier-cli info
zerotier-cli listnetworks

# Verify AdGuard is blocking
curl -s http://192.168.1.54:3002  # Web UI

# Verify RustDesk relay
# Connect from phone to z0r0 via RustDesk
```

---

## Troubleshooting

### DNS not blocking ads on a device
- Check device DNS: `nslookup` should show 192.168.1.54
- If device has hardcoded DNS (e.g., 8.8.8.8), it bypasses AdGuard
- Fix: Set DNS on device manually to 192.168.1.54, or enable gateway.nix DNS hijacking

### Tailscale can't connect to Headscale
- Verify port 8086 is forwarded on Spectrum router
- Check: `curl https://headscale.lovelain.duckdns.org` from external network
- Headscale ACL file must exist: `/var/lib/headscale/acl/hujson`

### WireGuard not connecting
- Verify port 51820 UDP is forwarded on Spectrum router
- Check luffy's public endpoint: `nixfp.duckdns.org:51820`
- Clan handles key generation automatically

### ZeroTier not joining
- Check luffy is controller: `zerotier-cli info` should show ONLINE
- Network ID from Clan: check `clan vars list` for zerotier network ID
- Join from devices using the network ID

### Luffy's IP changed
- If luffy gets a different IP, update:
  1. IP reservation on Spectrum router
  2. `gateway.lanIp` in `machines/luffy/default.nix`
  3. `adguard.gatewayIp` in `machines/luffy/default.nix`
  4. Port forwarding rules on Spectrum router