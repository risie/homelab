[ Laptop ] + [ Tillitis TKey ] + [ SOPS / Age ]
                           |  (Krypterade secrets dekrypteras lokalt)
                           v
NIVÅ 1: INFRA        [ 3x Proxmox VE Fysiska Noder (iPXE / PXE Boot) ]
(Hårdkodad Auth)           |---> 3x Flatcar VMs (DNS: Pi-hole + Unbound) [Wazuh Agent]
                           |---> 1x Flatcar VM (Lastbalanserare: HAProxy + Keepalived)
                           v  (Skapar en fast Virtuell IP / VIP)
NIVÅ 2: PLATTFORM    [ Cluster API (CAPI) ] ---> Styr och skalar Talos-noder automatiskt
(TLS-Certifikat)           |---> [ Talos Linux HA-Kluster (Kubernetes) ]

                           |         |---> [ GitOps: ArgoCD / FluxCD ]
                           |         |---> [ Krypterad Lagring: Garage S3 ]
                           v         v
NIVÅ 3: APPLIKATION  [ Säkerhets- & Kärntjänster ]     [ Säkerhet & Test ]
(Authentik SSO)            |---> Forgejo (Lokalt Git)        |---> Chaos Mesh (Chaos Monkey)

                           |---> Authentik (Identity/SSO)    |---> Wazuh Server (SIEM)
                           |---> Pangolin (Ingress Proxy)    |---> Gitea Actions (SAST/SBOM)




NIVÅ 0: TILLIT       [ Laptop ] + [ Tillitis TKey ] + [ SOPS / Age ]
                           |  (Krypterade secrets dekrypteras lokalt i stunden)
                           v
NIVÅ 1: HYPERVISOR   [ 3x Proxmox VE Fysiska Noder (iPXE / PXE Boot) ]
                           |  (Ingen data sparas lokalt på Proxmox-diskarna)
                           +------------------------+

                           |                        |
                           v                        v
NIVÅ 2: PLATTFORM    [ KLUSTER A: INFRA ]     [ KLUSTER B: APPAR ]
(TLS-Certifikat)     (3x Talos Linux VMs)     (3x Talos Linux VMs)

                           |                        |
                           |---> Kube-VIP           |---> Cluster API (CAPI)
                           |---> Pi-hole            |---> GitOps (ArgoCD)
                           |---> Unbound            |---> Storage CSI (NFS/iSCSI)
                           v                        v
NIVÅ 3: APPLIKATION  [ Helt oberoende ]       [ Centraliserad Auth ]
                     Körs helt i RAM.          |---> Forgejo (Lokalt Git)
                     Hårdkodad konfig.         |---> Authentik (SSO)
                     Ingen extern Auth.    |---> Pangolin (Ingress Proxy)
                                               |---> Grafana LGTM (Logg/Larm)
                                                    |
                                                    v
EXTERN LAGRING       [ EXTERNA NASEN (Krypterade Volymer via NFS/iSCSI) ]



Ansvars- & ÖverlämningsmatrisNivåKomponenterHur det provisionerasAnsvarig för Autentisering (Auth)Är det Core? (Kritisk för boot)LagringstypNivå 0Laptop, Tillitis TKey, SOPS, Lokalt Git-repo.Manuellt / Lokalt på din bärbara maskin.Tillitis TKey Kryptografi. Genereras i stunden på hårdvaran.JA. Utan din fysiska sticka kan inga hemligheter låsas upp.Lokalt på din laptop (Git).Nivå 1Proxmox VE (3 noder).iPXE-boot från din laptop med automatisk Answer File.Lokal hårdkodad auth. FIDO2 direkt i Proxmox (ingen extern SSO).JA. Detta är hårdvarufundamentet.Ingen data sparas lokalt.Nivå 2 (A)Kluster A (Infra): Talos Linux, Kube-VIP, Pi-hole + Unbound.OpenTofu (från laptopen) pratar med Proxmox API via lokala tokens.Kryptografiska TLS-certifikat. Talos tillåter varken lösenord eller SSH.JA. Hela nätverket och namnupplösningen måste finnas för att resten ska starta.Ingen. Körs helt i RAM ur hårdkodad kod.Nivå 2 (B)Kluster B (Appar): Cluster API (CAPI), Talos Linux, Storage CSI.OpenTofu bootstrappar CAPI, som sedan automatiskt skalar Talos-noder utifrån din kod.Kryptografiska TLS-certifikat. Samma princip som Kluster A.Delvis. Måste fungera för dina egna appar, men påverkar inte husets internet eller DNS.Persistent. Monterar krypterade nätverksvolymer från din NAS.Nivå 3Forgejo, Authentik, Pangolin, Grafana LGTM, Chaos Mesh.GitOps (ArgoCD) läser ditt monorepo och rullar ut apparna automatiskt i Kluster B.Authentik (SSO / OIDC). Här loggar du in med ditt centrala användarkonto.NEJ. Om Authentik dör kan du inte nå dina appar, men din infra (Kluster A) lever vidare.Persistent. All app-data skrivs direkt till din externa NAS via CSI.
oberoende



VyOs !!!!



Här är den kompletta och slutgiltiga konfigurationsfilen i Markdown. Du kan kopiera hela detta block och spara det som README.md eller ARCHITECTURE.md i roten av ditt monorepo. Den fungerar nu som din exakta kompass och tekniska specifikation för ditt framtida labb.markdown# 🗺️ Arkitekturritning: Det Ultimata Zero-Trust Hemlabbet

Detta dokument definierar målbilden för ett stensäkert, minimalistiskt och resilient private cloud byggt med principen **KISS (Keep It Simple, Stupid)**. Genom att eliminera traditionella serverdistributioner till förmån för **Talos Linux överallt** och ett **Pure Overlay Network**, minimeras den kognitiva belastningen samtidigt som hönan-och-ägget-problemet raderas till 100 %.

---

## 🏗️ Arkitekturöversikt (Pure Overlay & Identity-First)

Använd koden med försiktighet.NIVÅ 0: TILLIT       [ Laptop ] + [ Tillitis TKey ]|  (Secrets injiceras som miljövariabler vid körning)vNIVÅ 1: HYPERVISOR   [ 3x Proxmox VE Fysiska Noder (iPXE / Ephemeral) ]|  (Ingen lokal lagring. Endast beräkningskraft)+----------------------------------------+|                                        |v                                        vNIVÅ 2: NET / PLAT   [ VyOS Virtuell Router ]                [ 1x Talos Linux HA-Klustret ](KISS / Kodbaserat)  (Isolerar labbet från hemmet.           (3x VMs i HA på Proxmox.Drar minimalt med RAM / CPU)            Körs med Cilium eBPF-nätverk)AI-svar kan innehålla fel. Läs mercontinuemarkdown                                                                    |
                                                                    |-- Tailscale Operator (Nätverk/MagicDNS/TLS)
                                                                    |-- Cilium NetworkPolicies (L7 App-isolering)
                                                                    |-- Storage CSI (NFS/iSCSI mot extern NAS)
                                                                    |
                                                                    v
NIVÅ 3: GITOPS       [ Applikationer & Identitet ] ------------------+
(Inga fasta lösen)         |               |                |              |
                      [ Forgejo ]    [ Authentik ]    [ OpenBao ]    [ Pi-hole + Unbound ]
                      (Lokalt Git)    (Identity/SSO)   (Lösen-rot)    (DoH / DNS-sinking)

                           |               |                |              |
                           +---------------+----------------+--------------+
                                           |
                                           v
EXTERN LAGRING       [ EXTERNA NASEN (Krypterade Volymer via NFS/iSCSI) ]
                     (Den ENDA statiska punkten i labbet. All permanent data bor här)
Använd koden med försiktighet.📊 Ansvars- & ÖverlämningsmatrisNivåKomponenterHur det provisionerasAnsvarig för Autentisering (Auth)Är det Core? (Kritisk för boot)LagringstypNivå 0Laptop, Tillitis TKey, SOPS, Lokalt Git-repo.Manuellt / Lokalt på din bärbara maskin.Tillitis TKey Kryptografi. Genereras i stunden på hårdvaran [^1^].JA. Utan din fysiska sticka kan inga hemligheter låsas upp.Lokalt på din laptop (Git).Nivå 1Proxmox VE (3 noder).iPXE-boot från din laptop med automatisk Answer File.Lokal hårdkodad auth. FIDO2 direkt i Proxmox (ingen extern SSO) [^1^].JA. Detta är hårdvarufundamentet.Ingen data sparas lokalt.Nivå 2 (Net)VyOS Virtuell Router: Textbaserad brandvägg/router [^1^].OpenTofu (från laptopen) pratar med Proxmox API via lokala tokens.Lokal hårdkodad auth. SSH-nycklar skyddade av din hårdvarunyckel [^1^].JA. Isolerar labbet från hemmet och agerar internet-gateway.Ephemeral. Läser konfiguration som kod vid boot.Nivå 2 (Plat)Talos Linux HA-Kluster: 3x VMs i HA, Cilium CNI (eBPF).OpenTofu bootstrappar CAPI, som sedan automatiskt skalar Talos-noder utifrån din kod.Kryptografiska TLS-certifikat. Talos tillåter varken lösenord eller SSH [^1^].JA. Grunden för att kunna starta några applikationer överhuvudtaget.Ephemeral. Alla noder körs helt i RAM [^1^].Nivå 3Forgejo, Authentik, OpenBao, Pi-hole + Unbound, Grafana LGTM.GitOps (ArgoCD) läser ditt monorepo och rullar ut apparna automatiskt i klustret.Authentik (SSO / OIDC). Här loggar du in med ditt centrala användarkonto.NEJ. Om Authentik dör kan du inte nå dina appar, men din infra (VyOS/Talos) lever vidare [^1^].Persistent. All app-data skrivs direkt till din externa NAS via CSI.🔒 Säkerhetsdesign & "Least Privilege"1. Det Dubbla Försvaret (Nätverk + Identitet)Tailscale Operator (Nätverkslagret): Inga nätverksportar exponeras mot det lokala LAN-nätverket. När du lägger till annotationen ://tailscale.com: "true" på en Kubernetes-service [^1^], registrerar operatorn den automatiskt i ditt Mesh-VPN via MagicDNS (t.ex. n8n.labb.ts.net). Tailscale utfärdar dessutom äkta Let's Encrypt TLS-certifikat automatiskt [^1^]. Din Tailscale OAuth-token injiceras som en miljövariabel vid körning och sparas aldrig i Git.Authentik (Identitetslagret): Alla mänskliga användare (Du och Din fru) bor uteslutande i Authentik [^1^]. Inga lokala konton eller lösenord skapas i apparna (som Forgejo eller n8n) [^1^]. När en app öppnas kräver Authentik validering via OIDC/SAML och din fysiska Tillitis TKey (WebAuthn/FIDO2).2. Uppdelning av Användarroller (Minsta möjliga behörighet)Grupp: Labb-Admins (Bara Du): Kopplas till administrativa verktyg som Forgejo, OpenBao och Grafana. Kräver din Tillitis-sticka.Grupp: Hem-Användare (Du och Din fru): Har noll tillgång till infrastrukturen eller källkoden. Denna grupp ser och når endast konsument-appar (t.ex. Nextcloud eller Plex). Om din frus konto skulle bli kapat, kan angriparen inte nå eller modifiera labbet.Service Accounts (Maskin-till-maskin): Appar som behöver prata med varandra använder tidsbegränsade OAuth-tokens från Authentik eller dynamiska lösenord från OpenBao [^1^]. De tillåts aldrig använda personliga administratörskonton.3. Nätverkskryptering & Mikrosegmentering (Cilium eBPF)WireGuard i Kärnan: Cilium krypterar automatiskt all nätverkstrafik mellan dina tre fysiska Proxmox-noder på kernel-nivå via WireGuard. Trafik som färdas över dina fysiska kablar i huset är helt oläsbar.Lager 7-brandvägg (NetworkPolicies): Klustret körs i ett "Default Deny"-läge där alla poddar är helt isolerade från varandra som standard. Cilium eBPF används för att skriva specifika regler på applikationsnivå (t.ex. "App A får bara prata med App B på URL:en /api/v1/login").4. Krypterad DNS-Sinking & PrivacyPi-hole + Unbound: Körs som vanliga poddar i klustret. Unbound gör rekursiv DNS-uppslagning direkt mot internets rot-servrar. All utgående trafik krypteras med DNS-over-HTTPS (DoH) eller DNS-over-TLS (DoT) innan den lämnar VyOS-routern, vilket döljer din historik från din internetleverantör.Global Tailscale DNS: Pi-hole exponeras säkert via Tailscale Operator. Genom att sätta ditt kluster-Pi-hole som din globala namnserver i Tailscale, skickas all din nätverkstrafik (oavsett om du är hemma eller på ett publikt café) krypterat till ditt eget labb för fullständig reklamblockering och integritet.📁 Monorepo- & Mappstrukturtextmitt-zero-trust-labb/
├── .sops.yaml                      # Konfiguration för Tillitis TKey + SOPS/Age
│
├── 🛠️ bootstrap-laptop/             # KÖRS ENBART FRÅN LAPTOP VID START/KATASTROF
│   ├── main.tf                     # Providers (Proxmox, Talos, VyOS, Authentik)
│   ├── variables.tf                # Definitioner för miljövariabler
│   │
│   ├── 01-network.tf               # Skapar VyOS-VM:en i Proxmox & sätter VLAN-gränser
│   ├── 02-platform.tf              # Skapar 3x Talos-VMs via Cluster API (CAPI)
│   ├── 03-cni-cilium.tf            # Injicerar Cilium (eBPF, WireGuard-kryptering)
│   ├── 04-gitops-init.tf           # Bootstrappar ArgoCD (inline i Talos vid boot)
│   └── 05-authentik-setup.tf       # Skapar användare/roller i en tom Authentik via API
│
└── 🔄 gitops-apps/                  # STYRS HELT AV ARGOCD (VARDAGLIG DRIFT / GITOPS)
    ├── core-services/              # Kärntjänster (Körs i "militärt" läge)
    │   ├── tailscale-operator.yaml # Registrerar appar i din Tailnet via MagicDNS
    │   └── openbao.yaml            # Hanterar dynamisk rotation av interna lösenord
    │
    ├── identity/
    │   └── authentik-app.yaml      # Själva Authentik-applikationen (kopplad mot NAS)
    │
    ├── vcs/
    │   └── forgejo-app.yaml        # Forgejo (Git & Actions) + Storage CSI-koppling
    │
    └── custom-apps/                # Dina egna labbar (n8n, Nextcloud, etc.)
        ├── n8n/
        │   ├── deployment.yaml     # n8n poddar
        │   └── network-policy.yaml # Cilium eBPF-regel: Får BARA prata med Forgejo/OIDC
        └── ctf-sandbox/            # Hårt isolerad labbyta för sårbara maskiner
Använd koden med försiktighet.
