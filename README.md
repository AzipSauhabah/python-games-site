# AzipSauhabah — Python Game Projects (NAS Edition)

Site vitrine + jeux jouables en WebAssembly, hébergé sur NAS Synology.

## Architecture

```
/volume1/docker/python-games/
├── docker-compose.yml        ← démarrage du conteneur Nginx
├── nginx/
│   └── nginx.conf            ← headers COOP/COEP requis pour WASM
├── scripts/
│   └── build_mario.sh        ← build pygbag → WASM
└── frontend/
    ├── index.html            ← site vitrine
    └── games/
        └── mario/            ← build WASM généré par pygbag
            ├── index.html
            ├── Mario-Level-1-master.apk
            └── ...
```

## Déploiement initial

### 1. Copier les fichiers sur le NAS

```bash
scp -r python-games-site/ sauhabahaz@192.168.1.47:/volume1/docker/python-games
```

### 2. Builder Mario en WASM (une seule fois)

```bash
ssh sauhabahaz@192.168.1.47
cd /volume1/docker/python-games
sudo bash scripts/build_mario.sh
```

> ⚠️ Le premier build télécharge CPython WASM (~30 MB). Durée : 3-5 min.
> Les builds suivants sont beaucoup plus rapides (cache).

### 3. Démarrer le conteneur Nginx

```bash
cd /volume1/docker/python-games
sudo docker-compose up -d
```

### 4. Vérifier que ça tourne

```bash
curl http://192.168.1.47:3100
# Doit retourner le HTML du site
```

## Cloudflare Tunnel

Ajouter une route dans ton tunnel existant :

- **Subdomain** : `games`
- **Domain** : `sauhabah-advisory.eu`
- **Service** : `http://localhost:3100`

Le jeu sera accessible sur : **https://games.sauhabah-advisory.eu**

## Mise à jour du repo

Après un `git push` sur le repo PythonProjects :

```bash
ssh sauhabahaz@192.168.1.47
cd /volume1/docker/python-games
sudo bash scripts/build_mario.sh   # rebuid Mario
sudo docker-compose restart         # rechargement Nginx
```

## Ajouter un nouveau jeu (ex: Pacman)

1. Dupliquer `scripts/build_mario.sh` → `scripts/build_pacman.sh`
2. Changer `MARIO_DIR` → `Pacman-master`
3. Adapter le `main.py` async si besoin
4. Le jeu apparaît dans le dossier `games/pacman/`
5. Dans `frontend/index.html`, passer `playable: true` pour Pacman

## Ports

| Service       | Port NAS | URL externe                              |
|---------------|----------|------------------------------------------|
| python-games  | 3100     | https://games.sauhabah-advisory.eu       |

## Notes importantes

- Les headers **COOP/COEP** dans nginx.conf sont **obligatoires** pour que
  `SharedArrayBuffer` fonctionne (requis par pygbag/WASM).
- Ne pas exposer le port 5432 (conflit NAS natif) — sans objet ici.
- Le build pygbag doit être fait sur une machine avec accès internet
  (le NAS télécharge les binaires WASM depuis cdn.pygbag.org).
