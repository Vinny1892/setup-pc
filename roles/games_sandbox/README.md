# games-sandbox

Ambiente isolado para rodar jogos não confiáveis usando distrobox (CachyOS) + bubblewrap.

## Estrutura

```
~/games-sandbox/
├── Containerfile          # imagem CachyOS com libs gráficas e Vulkan
├── games/                 # jogos instalados manualmente (fora do Heroic)
├── wine-prefixes/         # wine prefixes manuais (--install / --run)
└── home/                  # home do distrobox
    ├── bwrap-game.sh      # wrapper bubblewrap — usado pelo Heroic e manualmente
    ├── heroic-launch.sh   # lança o Heroic Games Launcher
    ├── heroic/            # Heroic AppImage extraído
    └── Games/Heroic/
        └── Prefixes/      # wine prefixes gerenciados pelo Heroic
```

## Instalação

```bash
ansible-playbook playbook.yml --tags games_sandbox
```

O playbook:
1. Constrói a imagem `localhost/games-sandbox-image` com podman
2. Cria o distrobox `games-sandbox` com home em `~/games-sandbox/home`
3. Baixa e extrai o Heroic Games Launcher
4. Faz symlink do proton-cachyos e proton-cachyos-slr do host para o Heroic
5. Cria a entrada no menu de aplicativos

**Pré-requisito:** `proton-cachyos` instalado no host em `/usr/share/steam/compatibilitytools.d/`.

## Abrir o Heroic

Pelo menu de aplicativos: **Heroic Games Launcher (games-sandbox)**

Ou pelo terminal:

```bash
distrobox enter games-sandbox -- /home/vinny/games-sandbox/home/heroic-launch.sh
```

## Configurar um jogo no Heroic

Em **Settings → Wine** do jogo:

| Campo | Valor |
|---|---|
| Wine / Proton | `proton-cachyos` |
| Wine Prefix | `~/Games/Heroic/Prefixes/<nome-do-jogo>` |
| Wrapper | `/home/vinny/games-sandbox/home/bwrap-game.sh` |

O wrapper isola o processo do jogo dentro de um segundo bubblewrap, bloqueando acesso ao home real do host.

## Instalar um jogo manualmente (fora do Heroic)

```bash
distrobox enter games-sandbox -- \
  /home/vinny/games-sandbox/home/bwrap-game.sh --install /caminho/para/setup.exe nome-do-prefix
```

O instalador roda com proton-cachyos. O wine prefix é criado em `~/games-sandbox/home/wine-prefixes/<nome-do-prefix>`.

Se `nome-do-prefix` for omitido, usa o nome do arquivo `.exe` sem extensão.

## Rodar um jogo instalado manualmente

```bash
distrobox enter games-sandbox -- \
  /home/vinny/games-sandbox/home/bwrap-game.sh --run /caminho/para/jogo.exe nome-do-prefix
```

Se `nome-do-prefix` for omitido, usa o nome do diretório pai do executável.

## Como o isolamento funciona

```
host (Arch/CachyOS)
└── distrobox games-sandbox  (CachyOS container via podman)
    └── bwrap (bubblewrap)
        └── processo do jogo
```

Dentro do bwrap:

- `/home` vira tmpfs — o jogo não vê `~` do host
- `/run/host/home` e `/run/host/root` viram tmpfs — bloqueia acesso ao host via distrobox
- Apenas paths explícitos são montados com escrita: wine prefix, arquivos do jogo, cache, ferramentas do Heroic
- Wayland, PipeWire e PulseAudio são expostos via socket

## NVIDIA / Vulkan

O bwrap expõe `/run/host/usr/lib` como `/usr/lib/nvidia-host` para que o pressure-vessel (runtime do Proton) encontre `libGLX_nvidia.so` e suas dependências sem quebrar o caminho gerado pelo `capsule-capture-libs`.

O ICD está pré-configurado em `/etc/vulkan/icd.d/nvidia_icd.json` dentro da imagem.

## Atualizar o Heroic

Apague `~/games-sandbox/home/heroic/` e rode o playbook novamente — ele baixa a versão mais recente automaticamente.

```bash
rm -rf ~/games-sandbox/home/heroic
ansible-playbook playbook.yml --tags games_sandbox
```
